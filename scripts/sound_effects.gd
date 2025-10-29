extends AudioStreamPlayer

var ball_burst = preload("res://sounds/BallBurst.wav")
var ball_burst2 = preload("res://sounds/BallBurst2.wav")

func _ready() -> void:
    volume_db = -6
    max_polyphony = 16

func play_ball_burst() -> void:
    stream = ball_burst2
    play()
