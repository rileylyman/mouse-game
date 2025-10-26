extends AudioStreamPlayer

var ball_burst = preload("res://sounds/BallBurst.wav")

func play_ball_burst() -> void:
    stream = ball_burst
    play()
