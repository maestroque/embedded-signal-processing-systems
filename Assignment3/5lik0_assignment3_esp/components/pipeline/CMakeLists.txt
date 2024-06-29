set(COMPONENT_SRCS "pipeline.c")
set(COMPONENT_ADD_INCLUDEDIRS ".")
set(COMPONENT_REQUIRES audio_pipeline audio_sal bluetooth_service peripherals filter events static)

register_component()

