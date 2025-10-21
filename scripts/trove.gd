class_name Trove extends Area2D

@export var dot_radius: float = 200.0
@export var dot_min_radius: float = 80.0

@onready var health: float = GameManager.trove_health
@onready var health_bar: HealthBar = $HealthBar

var dot_res = preload("res://scenes/dot.tscn")

func _ready() -> void:
    _produce_dots_async()

func _produce_dots_async() -> void:
    await get_tree().create_timer(randf()).timeout
    while true:
        var dot = dot_res.instantiate()
        dot.global_position = global_position
        dot.target = global_position + Vector2(2.0 * randf() - 1.0, 2.0 * randf() - 1.0).normalized() * (dot_min_radius + randf() * (dot_radius - dot_min_radius))
        get_tree().current_scene.add_child.call_deferred(dot)
        await get_tree().create_timer(1.0 / GameManager.trove_gps).timeout

func take_damage(damage: float) -> bool:
    health = max(health - damage, 0)
    health_bar.health_t = health / GameManager.trove_health
    if health <= 0:
        queue_free()
        return true
    else:
        return false
