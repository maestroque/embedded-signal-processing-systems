#pragma once

#include "esp_err.h"
#include "audio_element.h"

/**
 * @brief      Custom filter Configuration
 */
typedef struct {
    int out_rb_size; /*!< Size of output ring buffer */
    int task_stack;  /*!< Task stack size */
    int task_core;   /*!< Task running in core...*/
    int task_prio;   /*!< Task priority*/
    int misses;      /*!< Number of deadline misses before aborting */
} filter_cfg_t;

#define DEFAULT_FILTER_CONFIG() {                    \
        .out_rb_size    = 4 * 1024,                  \
        .task_stack     = 4 * 1024,                  \
        .task_core      = 1,                         \
        .task_prio      = 5,                         \
        .misses         = 100,                       \
    }

// toggle filter on/off
bool toggle_filter(audio_element_handle_t self);

void filter_set_sample_rate(audio_element_handle_t self, uint32_t sample_rate);

// initialize the filter configuration
audio_element_handle_t filter_init(filter_cfg_t *config);

// access the the filter element handle
extern audio_element_handle_t filter_el;

