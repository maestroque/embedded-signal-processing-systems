#include "peripherals.h"

#include <periph_button.h>
#include <periph_touch.h>

esp_periph_handle_t bt_periph = NULL;
audio_board_handle_t board_handle = NULL;


esp_err_t audio_board_lyrat_key_init(esp_periph_set_handle_t set)
{
    periph_button_cfg_t btn_cfg = {
        .gpio_mask = (1ULL << get_input_rec_id()) | (1ULL << get_input_mode_id()), // REC BTN & MODE BTN
    };

    esp_periph_handle_t button_handle = periph_button_init(&btn_cfg);
    AUDIO_NULL_CHECK("AUDIO_BOARD", button_handle, return ESP_ERR_ADF_MEMORY_LACK);
    esp_err_t ret = ESP_OK;
    ret = esp_periph_start(set, button_handle);
    if (ret != ESP_OK)
    {
            return ret;
    }

    periph_touch_cfg_t touch_cfg = {
        // Do not enable touch pad sel 4 (Vol-) as it is used for JTAG
        .touch_mask = TOUCH_PAD_SEL7 | TOUCH_PAD_SEL8 | TOUCH_PAD_SEL9,
        .tap_threshold_percent = 70,
    };

    esp_periph_handle_t touch_periph = periph_touch_init(&touch_cfg);
    AUDIO_NULL_CHECK("AUDIO_BOARD", touch_periph, return ESP_ERR_ADF_MEMORY_LACK);
    ret = esp_periph_start(set, touch_periph);
    return ret;
}

