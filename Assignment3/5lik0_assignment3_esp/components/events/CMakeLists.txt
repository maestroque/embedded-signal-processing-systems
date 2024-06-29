set(COMPONENT_SRCS "events.c")
set(COMPONENT_ADD_INCLUDEDIRS ".")
set(COMPONENT_REQUIRES esp_peripherals audio_pipeline audio_sal bluetooth_service peripherals pipeline filter static)

register_component()

