extends Node

var time_s: float = 0

var desired_time_scale: float = 1.0

func _process(_delta: float) -> void:
    time_s += _delta

    if Input.is_physical_key_pressed(KEY_ALT):
        if Input.is_physical_key_pressed(KEY_1):
            desired_time_scale = 1.0
        elif Input.is_physical_key_pressed(KEY_2):
            desired_time_scale = 0.25
        elif Input.is_physical_key_pressed(KEY_3):
            desired_time_scale = 0.5
        elif Input.is_physical_key_pressed(KEY_4):
            desired_time_scale = 2.0
        elif Input.is_physical_key_pressed(KEY_5):
            desired_time_scale = 4.0
        elif Input.is_physical_key_pressed(KEY_6):
            desired_time_scale = 8.0

    if BeatManager.fast_forward:
        Engine.time_scale = 10.0
        AudioServer.playback_speed_scale = 10.0
    else:
        Engine.time_scale = desired_time_scale
        AudioServer.playback_speed_scale = desired_time_scale
