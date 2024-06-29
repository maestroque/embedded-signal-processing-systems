set(COMPONENT_SRCS "peripherals.c")
set(COMPONENT_ADD_INCLUDEDIRS ".")
set(COMPONENT_REQUIRES audio_pipeline audio_sal audio_hal audio_board esp_peripherals)

register_component()

