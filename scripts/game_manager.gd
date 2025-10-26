extends Node

var time_s: float = 0

func _process(_delta: float) -> void:
    time_s += _delta
    if Input.is_physical_key_pressed(KEY_ALT):
        if Input.is_physical_key_pressed(KEY_1):
            Engine.time_scale = 1.0
            AudioServer.playback_speed_scale = 1.0
        elif Input.is_physical_key_pressed(KEY_2):
            Engine.time_scale = 2.0
            AudioServer.playback_speed_scale = 2.0
        elif Input.is_physical_key_pressed(KEY_3):
            Engine.time_scale = 3.0
            AudioServer.playback_speed_scale = 3.0
        elif Input.is_physical_key_pressed(KEY_4):
            Engine.time_scale = 4.0
            AudioServer.playback_speed_scale = 4.0