extends AudioStreamPlayer

var ball_burst = preload("res://sounds/BallBurst.wav")
var ball_burst2 = preload("res://sounds/BallBurst2.wav")

var i = 0

func _ready() -> void:
    max_polyphony = 16

func play_ball_burst() -> void:
    stream = ball_burst2
    play()
