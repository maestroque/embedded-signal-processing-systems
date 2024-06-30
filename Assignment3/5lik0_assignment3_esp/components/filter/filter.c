
#include "filter.h"

#include "filtercoefficients.h"

#include <audio_error.h>
#include <audio_mem.h>
#include <esp_log.h>
#include <inttypes.h>

// expose handle to the filter element, set in the pipeline construction
audio_element_handle_t filter_el = NULL;

static const char *TAG = "FIR-FILTER";

#define DEFAULT_SAMPLING_RATE 44100

static const int BYTES_PER_RL_SAMPLE = 4; // 2 bytes per sample, 2 channels

typedef struct {
	bool filter_on;
	unsigned int index; // Index for the circular buffer
	// two circular buffers (left/right) to hold the old samples for the FIR convolution 
	int16_t buffer_left[FIR_FILTER_LENGTH]; // FIR_FILTER_LENGTH is defined in filtercoefficients.h
	int16_t buffer_right[FIR_FILTER_LENGTH];

	int64_t max_us; // maximum delay 
	int32_t buffer_size; // maximum size of the input buffer
	int16_t misses; // Number of misses so far
} filter_t;


// toggle the filter on or off
bool toggle_filter(audio_element_handle_t self) {
	filter_t *filter = (filter_t *)audio_element_getdata(self);
	filter->filter_on = ! filter->filter_on;
	return filter->filter_on;
}

void filter_set_sample_rate(audio_element_handle_t self, uint32_t rate) {
	// Compute max microseconds depending on input buffer and number of samples
	filter_t *filter = (filter_t *)audio_element_getdata(self);
	filter->max_us = (filter->buffer_size / BYTES_PER_RL_SAMPLE) * 1000000UL / rate;
	ESP_LOGI(TAG, "Max filter us: %" PRId64, filter->max_us);
}

// this function is called when the filter starts
static esp_err_t filter_open(audio_element_handle_t self) {
    
    ESP_LOGI(TAG, "The filter is starting");
	filter_t *filter = (filter_t *)audio_element_getdata(self);

   	/* initialize the circular buffer */
   	for (int i = 0  ; i < FIR_FILTER_LENGTH  ; i++ )
   	{
   		filter->buffer_left[i] = 0;
   		filter->buffer_right[i] = 0;
   	}
   
    return ESP_OK;
}

// this function is called when the filter stops
static esp_err_t filter_close(audio_element_handle_t self) {
	ESP_LOGI(TAG, "The filter is stopping");
	return ESP_OK;
}

// this function is called when the filter is destroyed
static esp_err_t filter_destroy(audio_element_handle_t self) {
	filter_t *filter = (filter_t *)audio_element_getdata(self);
	audio_free(filter);
	return ESP_OK;
}

// Perform a filter operation on a pair of Left-Right samples
// output samples should be assigned to *left_output and *right_output
inline static void filter_sample(filter_t *filter, int16_t left_input, int16_t right_input, int16_t *left_output, int16_t *right_output) {

	// update the buffer index
	filter->index++;
	if(filter->index >= FIR_FILTER_LENGTH) filter->index = 0;

	// store the new samples in the circular buffers
	filter->buffer_left[filter->index] = left_input;
	filter->buffer_right[filter->index] = right_input;

	/* compute the filters output */
	int32_t accum_left = 0;
	int32_t accum_right = 0;
    uint32_t idx = filter->index;
	int16_t *buffer_left = filter->buffer_left;
	int16_t *buffer_right = filter->buffer_right;
	for (int j = 0  ; j < FIR_FILTER_LENGTH; j++ )
	{
		// do computations in 32 bit for accuracy, considering the fixed point representation of the
		// filter coefficients
		accum_left += (int32_t)buffer_left[idx] * (int32_t)FIRFilterCoefficients[j];
		accum_right += (int32_t)buffer_right[idx] * (int32_t)FIRFilterCoefficients[j];
		idx--;
        if (idx < 0) {
            idx = FIR_FILTER_LENGTH - 1;
        }
		filter->index = idx;
	}

	// divide the computed outputs according to the fixed point representation of the filter coefficients
	// if the filter coefficients have N fractional bits, we need to shit N bits
	*left_output = accum_left >> FIR_FRACTIONAL_BITS;
	*right_output = accum_right >> FIR_FRACTIONAL_BITS;
}

// This function is called from the ESP-ADF streaming pipeline
// self is the handle to the filter element
// in is a pointer to an input buffer filled with (many) samples
// len is the amount of data in the buffer, in bytes
static esp_err_t filter_process(audio_element_handle_t self, char *in, int len)
{

	filter_t *filter = (filter_t *)audio_element_getdata(self);

	int diff = len % BYTES_PER_RL_SAMPLE;
	if (diff != 0)
	{
		ESP_LOGD(TAG, "Need to adapt buffer length %d to %d", len, len - diff);
	}

	// Note: LR audio interleaves samples from left and right. So, we need to process 4 bytes at a time.
	// if we are not reading a multiple of 4 bytes, we only process until the multiple of 4.
	int r_size = audio_element_input(self, in, len - diff);
	if (r_size <= 0)
	{
		ESP_LOGE(TAG, "ALARM! %d", r_size);
		return r_size;
	}

	// start timer
	int64_t time_start = esp_timer_get_time();

	// If we did not get full samples, log a warning
	if (r_size % BYTES_PER_RL_SAMPLE != 0)
	{
		ESP_LOGW(TAG, "Could not get full samples");
	}

	// round to a set of complete samples
	int new_len = r_size - (r_size % 4);
	// compute how many samples we have
	int num_samples = new_len / BYTES_PER_RL_SAMPLE;

	// define buffer pointer to walk through the buffer
	int16_t *buffer = (int16_t *)in;

	// only if the filter toggle is on
	if (filter->filter_on)
	{
		// filter all samples in the buffer
		while (num_samples > 0)
		{
			// filter a single sample
			filter_sample(filter, buffer[0], buffer[1], &buffer[0], &buffer[1]);
			// next sample is 4 bytes, or 2 integers further:
			buffer += 2;
			--num_samples;
		}
	}

	// check the time the filtering took
	int time_us = esp_timer_get_time() - time_start;
	ESP_LOGW(TAG, "Filtering Time: %d us", time_us);
	// is it too much?
	if (time_us > filter->max_us)
	{
		filter->misses--;
		ESP_LOGW(TAG, "Time: %d, misses remaining %d", time_us, filter->misses);
		if (filter->misses <= 0) {
			return AEL_IO_ABORT;
		}
	}

	// Tell the audio framework how much output we have produced
	int nrProd = audio_element_output(self, in, new_len);
    // Return the amount of data produced
    return nrProd;
}

// initialize the filter element
audio_element_handle_t filter_init(filter_cfg_t *config) {
	// Check if something went wrong
	if (config == NULL) {
		ESP_LOGE(TAG, "Filter config is NULL");
		return NULL;
	}

	filter_t *filter = audio_calloc(1, sizeof(filter_t));
	AUDIO_MEM_CHECK(TAG, filter, return NULL);
	
	if (filter == NULL) {
		ESP_LOGE(TAG, "audio_calloc failed for filter.");
		return NULL;
	}

	// set up the configuration
	audio_element_cfg_t cfg = DEFAULT_AUDIO_ELEMENT_CONFIG();
    // Set filter callback functions
    cfg.open = filter_open;
    cfg.process = filter_process;
	cfg.close = filter_close;
	cfg.destroy = filter_destroy;
    cfg.tag = "filter";
	cfg.task_stack = config->task_stack;
	cfg.task_core = config->task_core;
	cfg.task_prio = config->task_prio;
	cfg.out_rb_size = config->out_rb_size;
    audio_element_handle_t el = audio_element_init(&cfg);

	filter->filter_on = true;
	filter->index = 0;
	filter->misses = config->misses;
	filter->buffer_size = cfg.buffer_len;
	audio_element_setdata(el, filter);
	filter_set_sample_rate(el, DEFAULT_SAMPLING_RATE);
	return el;
}
