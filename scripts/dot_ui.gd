extends Node2D

var target: Vector2
var speed: float = 1000.0

func _process(delta: float) -> void:
    global_position = global_position.move_toward(target, speed * delta)
    if global_position.distance_to(target) < 1:
        queue_free()
