package main

import ma "vendor:miniaudio"
import "core:math/rand"
import "core:fmt"
import "core:os"

SAMPLE_FORMAT :: ma.format.f32
SAMPLE_RATE   :: 48000
VOLUME        :: 0.002
CHANNELS      :: 2

data_callback :: proc "c" (device: ^ma.device, output, input: rawptr, frame_count: u32) {
    samples := ([^]f32)(output)
    sample_count := int(frame_count) * CHANNELS
    
    for i in 0..<sample_count {
        samples[i] = (^f32)(device.pUserData)^
    }
}

main :: proc() {
    rng := rand.default_random_generator()

    config := ma.device_config_init(.playback)
    config.playback.format = SAMPLE_FORMAT
    config.playback.channels = CHANNELS
    config.sampleRate = SAMPLE_RATE
    config.dataCallback = data_callback

    random_number := rand.float32_range(-1, 1)
    config.pUserData = &random_number

    device: ma.device

    result := ma.device_init(nil, &config, &device)
    if result != .SUCCESS do return
    defer ma.device_uninit(&device)

    ma.device_set_master_volume(&device, VOLUME)

    if ma.device_start(&device) != .SUCCESS do return

    for do random_number = rand.float32_range(-1, 1)

    fmt.println("Stopping audio device...")
}
