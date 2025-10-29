class_name LaserEffects extends AudioStreamPlayer

var laser_mid: AudioStream = preload("res://sounds/LaserMid.wav")

func _ready() -> void:
    stream = laser_mid
    volume_db = -6

func start_laser() -> void:
    if not is_playing():
        play()

func stop_laser() -> void:
    stop()
