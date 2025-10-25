class_name HeartBall extends Node2D

var dir: Vector2
var speed: float = 100.0

@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var paddle: Paddle = $"/root/Node2D/Paddle"

func _ready() -> void:
    dir = dir.normalized()
    $Area2D.area_entered.connect(_on_area_enter)
    speed = paddle.radius_max / (BeatManager.secs_per_beat * 2)

func _process(delta: float) -> void:
    global_position += dir * speed * delta

    var r = global_position.distance_to(heart.global_position)
    if r > 4000.0:
        queue_free()

func _on_area_enter(area: Area2D) -> void:
    if area.name == "PaddleArea":
        queue_free()
