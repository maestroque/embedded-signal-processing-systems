/* My Second Filter, running average

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/

#include "static.h"
#include "board_app.h"
#include "events.h"
#include "pipeline.h"

// change this to match your group number
#define BT_DEVICE_NAME "5LIK0-ESP-FILTER-GROUP-42"

void app_main(void)
{
    // set logging levels
    esp_log_level_set("*", ESP_LOG_WARN);
    esp_log_level_set(ESPTAG, ESP_LOG_DEBUG);

    // some initialization
    init_flash();

    // setup the audio pipeline with the given bluetooth name and start it
    setup_pipeline(BT_DEVICE_NAME);
    
    // start listening for events while the pipeline runs
    ESP_LOGI(ESPTAG, "Device name: %s", BT_DEVICE_NAME);
    ESP_LOGI(ESPTAG, "Listen for all pipeline events");   
    bool cont = true;
    while (cont) {
        // handle events, continue running of the return value is true, otherwise stop
        cont = listen_for_events();
    }

    // stop the pipeline
    stop_pipeline();

    // restart the board
    esp_restart();
}
