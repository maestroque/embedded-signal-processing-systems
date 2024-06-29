#pragma once

#include <esp_log.h>
#include <board.h>
#include <esp_peripherals.h>

extern esp_periph_handle_t bt_periph;
extern audio_board_handle_t board_handle;

esp_err_t audio_board_lyrat_key_init(esp_periph_set_handle_t set);
