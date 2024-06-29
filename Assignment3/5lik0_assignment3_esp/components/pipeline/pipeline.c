#include "pipeline.h"
#include "peripherals.h"
#include "events.h"
#include "static.h"
#include "filter.h"

// expose the shared handles to pipeline components
audio_element_handle_t i2s_stream_writer = NULL;
audio_pipeline_handle_t pipeline = NULL;
audio_element_handle_t bt_stream_reader = NULL;
esp_periph_set_handle_t set = NULL;


// setup the streaming pipeline using the provided name for the bluetooth device
void setup_pipeline(const char* bt_device_name) {

    esp_err_t err = nvs_flash_init();
    if (err == ESP_ERR_NVS_NO_FREE_PAGES) {
        // NVS partition was truncated and needs to be erased
        // Retry nvs_flash_init
        ESP_ERROR_CHECK(nvs_flash_erase());
        err = nvs_flash_init();
    }

    esp_log_level_set("*", ESP_LOG_WARN);
    esp_log_level_set(ESPTAG, ESP_LOG_DEBUG);

    ESP_LOGI(ESPTAG, "[ 1 ] Create Bluetooth service");
    bluetooth_service_cfg_t bt_cfg = {
        .device_name = bt_device_name,
        .mode = BLUETOOTH_A2DP_SINK,
    };
    bluetooth_service_start(&bt_cfg);
    ESP_LOGI(ESPTAG, "Sample rate %d", periph_bluetooth_get_a2dp_sample_rate());

    ESP_LOGI(ESPTAG, "[ 2 ] Start codec chip");
    board_handle = audio_board_init();
    audio_hal_ctrl_codec(board_handle->audio_hal, AUDIO_HAL_CODEC_MODE_DECODE, AUDIO_HAL_CTRL_START); 

    audio_hal_set_volume(board_handle->audio_hal, player_volume);
    audio_hal_get_volume(board_handle->audio_hal, &player_volume);

    ESP_LOGI(ESPTAG, "[ 3 ] Create audio pipeline for playback");
    audio_pipeline_cfg_t pipeline_cfg = DEFAULT_AUDIO_PIPELINE_CONFIG();
    pipeline = audio_pipeline_init(&pipeline_cfg);

    ESP_LOGI(ESPTAG, "[3.1] Get bluetooth stream");
    bt_stream_reader = bluetooth_service_create_stream();

    ESP_LOGI(ESPTAG, "[3.2] Create Filter Element");
    filter_cfg_t filter_cfg = DEFAULT_FILTER_CONFIG();
    filter_cfg.task_core = 1;
    filter_el = filter_init(&filter_cfg);

    ESP_LOGI(ESPTAG, "[3.3] Create i2s stream to write data to codec chip");
    i2s_stream_cfg_t i2s_cfg = I2S_STREAM_CFG_DEFAULT();
    // Set the sample rate of the i2s to ADC communication.
    // Perhaps this needs to be changed of the source uses a different sample rate (probably then 48000)
    i2s_cfg.i2s_config.sample_rate = 44100;
    i2s_cfg.task_core = 0;
    i2s_stream_writer = i2s_stream_init(&i2s_cfg);

    ESP_LOGI(ESPTAG, "[3.4] Register all elements to audio pipeline");
    audio_pipeline_register(pipeline, bt_stream_reader, "bt");
    audio_pipeline_register(pipeline, filter_el, "filter");
    audio_pipeline_register(pipeline, i2s_stream_writer, "i2s_write");

    ESP_LOGI(ESPTAG, "[3.5] [bluetooth]->bt->i2s_stream_writer->[codec_chip]");
    const char *link_tag[] = {"bt", "filter", "i2s_write"};
    esp_err_t res = audio_pipeline_link(pipeline, link_tag, 3);
    if (res == ESP_FAIL) {
        ESP_LOGE(ESPTAG, "Pipeline Link Failed.");
        return;
    }

    ESP_LOGI(ESPTAG, "[ 4 ] Initialize peripherals");
    esp_periph_config_t periph_cfg = DEFAULT_ESP_PERIPH_SET_CONFIG();
    set = esp_periph_set_init(&periph_cfg);

    ESP_LOGI(ESPTAG, "[4.1] Initialize keys on board");
    audio_board_lyrat_key_init(set);

    ESP_LOGI(ESPTAG, "[4.2] Create Bluetooth peripheral");
    bt_periph = bluetooth_service_create_periph();

    ESP_LOGI(ESPTAG, "[4.3] Start all peripherals");
    esp_periph_start(set, bt_periph);

    ESP_LOGI(ESPTAG, "[ 5 ] Set up  event listener");
    audio_event_iface_cfg_t evt_cfg = AUDIO_EVENT_IFACE_DEFAULT_CFG();
    evt = audio_event_iface_init(&evt_cfg);

    ESP_LOGI(ESPTAG, "[5.1] Listening event from all elements of pipeline");
    audio_pipeline_set_listener(pipeline, evt);

    ESP_LOGI(ESPTAG, "[5.2] Listening event from peripherals");
    audio_event_iface_set_listener(esp_periph_set_get_event_iface(set), evt);

    ESP_LOGI(ESPTAG, "[ 6 ] Start audio_pipeline");
    audio_pipeline_run(pipeline);
}


void stop_pipeline() {
    ESP_LOGI(ESPTAG, "[ 8 ] Stop audio_pipeline");
    audio_pipeline_stop(pipeline);
    audio_pipeline_wait_for_stop(pipeline);
    audio_pipeline_terminate(pipeline);

    audio_pipeline_unregister(pipeline, bt_stream_reader);
    audio_pipeline_unregister(pipeline, filter_el);
    audio_pipeline_unregister(pipeline, i2s_stream_writer);

    /* Terminate the pipeline before removing the listener */
    audio_pipeline_remove_listener(pipeline);

    /* Stop all peripherals before removing the listener */
    esp_periph_set_stop_all(set);
    audio_event_iface_remove_listener(esp_periph_set_get_event_iface(set), evt);

    /* Make sure audio_pipeline_remove_listener & audio_event_iface_remove_listener are called before destroying event_iface */
    audio_event_iface_destroy(evt);

    /* Release all resources */
    audio_pipeline_deinit(pipeline);
    audio_element_deinit(bt_stream_reader);
    audio_element_deinit(i2s_stream_writer);
    esp_periph_set_destroy(set);
    set = NULL;
    i2s_stream_writer = NULL;
    pipeline = NULL;
    bt_stream_reader = NULL;
    evt = NULL;
    bluetooth_service_destroy();
}
