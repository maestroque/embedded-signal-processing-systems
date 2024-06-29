#include "events.h"
#include "filter.h"
#include "static.h"
#include "peripherals.h"
#include "pipeline.h"

#include <esp_log.h>
#include <bluetooth_service.h>
#include <periph_button.h>
#include <periph_touch.h>

audio_event_iface_handle_t evt = NULL;

bool bt_playing = false;

bool listen_for_events() {
    audio_event_iface_msg_t msg;
    esp_err_t ret = audio_event_iface_listen(evt, &msg, portMAX_DELAY);
    if (ret != ESP_OK) {
        ESP_LOGE(ESPTAG, "[ * ] Event interface error : %d", ret);
        return true;
    }

    if (msg.source_type == AUDIO_ELEMENT_TYPE_ELEMENT) {
        // Stop when the last pipeline element (i2s_stream_writer in this case) receives stop event
        if (msg.cmd == AEL_MSG_CMD_REPORT_STATUS
            && (((int)msg.data == AEL_STATUS_STATE_STOPPED)
                || ((int)msg.data == AEL_STATUS_STATE_FINISHED))) {
            ESP_LOGW(ESPTAG, "[ * ] Stop event received");
            return false;
        } else if (msg.cmd == AEL_MSG_CMD_REPORT_MUSIC_INFO
                   && msg.source == (void *)bt_stream_reader) {
            audio_element_info_t music_info = {0};
            audio_element_getinfo(bt_stream_reader, &music_info);
            filter_set_sample_rate(filter_el, music_info.sample_rates);

            ESP_LOGI(ESPTAG,
                     "[ * ] Music info: sample_rate=%d, bits=%d, ch=%d",
                     music_info.sample_rates,
                     music_info.bits,
                     music_info.channels);
        }
    }

    /* Stop when the Bluetooth is disconnected or suspended */
    if (msg.source_type == PERIPH_ID_BLUETOOTH
        && msg.source == (void *)bt_periph) {
        if (msg.cmd == PERIPH_BLUETOOTH_DISCONNECTED) {
            ESP_LOGW(ESPTAG, "[ * ] Bluetooth disconnected");
            bt_playing = false;
            return false;
        } if (msg.cmd == PERIPH_BLUETOOTH_AUDIO_STARTED) {
            bt_playing = true;
        } if (msg.cmd == PERIPH_BLUETOOTH_AUDIO_STOPPED || msg.cmd == PERIPH_BLUETOOTH_AUDIO_SUSPENDED) {
            bt_playing = false;
        }
    }

    if ((msg.source_type == PERIPH_ID_TOUCH || msg.source_type == PERIPH_ID_BUTTON || msg.source_type == PERIPH_ID_ADC_BTN)
        && (msg.cmd == PERIPH_BUTTON_PRESSED)) {

        ESP_LOGI(ESPTAG, "[ * ] Button: %d", ((int) msg.data));

        if ((int) msg.data == get_input_mode_id()) {
            bool result = toggle_filter(filter_el);
            ESP_LOGI(ESPTAG, "[ * ] [mode] Filter %s", result ? "enabled" : "disabled");
        } else if ((int) msg.data == get_input_volup_id()) {
            ESP_LOGI(ESPTAG, "[ * ] [Vol+] touch tap event");
            // Wrap around because we cannot use the Vol- key
            player_volume += 10;
            if (player_volume > 100) {
                player_volume = 0;
            }
            audio_hal_set_volume(board_handle->audio_hal, player_volume);
            ESP_LOGI(ESPTAG, "[ * ] Volume set to %d %%", player_volume);
        } else if ((int) msg.data == get_input_set_id()) {
            ESP_LOGI(ESPTAG, "[ * ] [Set] touch tap event");
            periph_bluetooth_next(bt_periph);
        } else if ((int) msg.data == get_input_play_id()) {
            ESP_LOGI(ESPTAG, "[ * ] [Play] touch tap event");

            if (bt_playing) {
                periph_bluetooth_pause(bt_periph);
            } else {
                periph_bluetooth_play(bt_periph);
            }
        }
    }

    return true;
}
