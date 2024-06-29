#pragma once

#include <audio_pipeline.h>
#include <bluetooth_service.h>
#include <board.h>
#include <esp_avrc_api.h>
#include <esp_log.h>
#include <esp_peripherals.h>
#include <i2s_stream.h>
#include <nvs_flash.h>

audio_element_handle_t bt_stream_reader;

// setup the streaming audio pipeline using the provided name for the bluetooth device
void setup_pipeline(const char* bt_device_name);

// tear down the streaming audio pipeline
void stop_pipeline();