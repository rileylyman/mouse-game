class_name Trove extends Area2D

@export var health: float = 10.0
@export var dot_radius: float = 100.0
@export var dot_min_radius: float = 40.0

var dot_res = preload("res://scenes/dot.tscn")

func _ready() -> void:
    _produce_dots_async()

func _produce_dots_async() -> void:
    while true:
        var dot = dot_res.instantiate()
        dot.global_position = global_position
        dot.target = global_position + Vector2(2.0 * randf() - 1.0, 2.0 * randf() - 1.0).normalized() * (dot_min_radius + randf() * (dot_radius - dot_min_radius))
        get_tree().current_scene.add_child(dot)
        await get_tree().create_timer(1.0).timeout

func take_damage(damage: float) -> bool:
    health -= damage
    if health <= 0:
        queue_free()
        return true
    else:
        return false
