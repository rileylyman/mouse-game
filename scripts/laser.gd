class_name Laser extends Node2D

signal target_reached

var curr_angle: float = 0.0
var next_angle: float = 0.0
var time = 1.0

var _elapsed = 0.0
var reached = false

@onready var paddle: Paddle = $"/root/Node2D/Paddle"
@onready var paddle_area: Area2D = $"/root/Node2D/Paddle/Sprite2D/PaddleArea"
@onready var area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    rotation = curr_angle
    scale.x = 1000.0 / 64.0

func _process(delta: float) -> void:
    if paddle_area.overlaps_area(area):
        sprite.scale.x = paddle.radius / 1000.0
    else:
        sprite.scale.x = 1.0

    _elapsed += delta
    var t = clampf(_elapsed / time, 0, 1)
    rotation = lerpf(curr_angle, next_angle, t)

    if t == 1.0 and not reached:
        target_reached.emit()
        reached = true

func set_angle(_curr_angle: float, _next_angle: float, _time: float) -> void:
    assert(_time > 0)
    _elapsed = 0.0
    reached = false
    self.curr_angle = _curr_angle
    self.next_angle = _next_angle
    self.time = _time
