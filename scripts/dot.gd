extends Area2D

@export var speed: float = 1000.0
@export var drop_time: float = 0.5

@onready var _start_time: float = Time.get_ticks_msec() / 1000.0
@onready var _start_position: Vector2 = global_position
@onready var _player = $"/root/Node2D/MouseBody"

var target: Vector2
var picked_up = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _ease_speed(t: float) -> float:
    t = clamp(t / drop_time, 0.0, 1.0)
    return 1 - pow(1 - t, 5)

func _process(delta: float) -> void:
    var drop_t = clamp((Time.get_ticks_msec() / 1000.0 - _start_time) / drop_time, 0, 1)
    if drop_t < 1:
        global_position = lerp(_start_position, target, _ease_speed(drop_t))
    elif picked_up or not GameManager.in_round:
        global_position = global_position.move_toward(_player.global_position, speed * delta)
    
    if global_position.distance_to(_player.global_position) < 1:
        GameManager.gems += 1
        queue_free()

func _on_body_entered(body: RigidBody2D) -> void:
    if body is not MouseBody:
        return
    picked_up = true
