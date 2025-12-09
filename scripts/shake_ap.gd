extends AnimationPlayer

signal shake_loop

func on_shake_loop() -> void:
    shake_loop.emit()
