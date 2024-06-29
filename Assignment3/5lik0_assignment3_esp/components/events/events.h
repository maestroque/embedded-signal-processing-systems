#pragma once

#include <audio_pipeline.h>
#include <esp_peripherals.h>
#include <board.h>

extern audio_event_iface_handle_t evt;

bool listen_for_events();