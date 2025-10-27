class_name Laser extends Area2D

signal target_reached

var curr_angle: float = 0.0
var next_angle: float = 0.0
var time = 1.0
var charge_time = 1.0
var wait_charge = false
var show_pre = true

var _elapsed = 0.0
var reached = false

@onready var paddle: Paddle = $"/root/Node2D/Paddle"
@onready var paddle_area1: Area2D = $"/root/Node2D/Paddle/Sprite2D/PaddleArea"
@onready var paddle_area2: Area2D = $"/root/Node2D/Paddle/Sprite2D2/PaddleArea"
@onready var paddle_area3: Area2D = $"/root/Node2D/Paddle/Sprite2D3/PaddleArea"
@onready var sprite: Sprite2D = $Sprite2D
@onready var heart: Heart = $"/root/Node2D/Heart"
var particles_scene: PackedScene = preload("res://scenes/laser_particles.tscn")
var particles: CPUParticles2D

func _ready() -> void:
    particles = particles_scene.instantiate()
    particles.emitting = false
    get_tree().current_scene.add_child(particles)
    rotation = curr_angle
    scale.x = 1000.0 / 64.0
    sprite.scale.y = 0.1

func _get_overlapping_paddle() -> Area2D:
    if overlaps_area(paddle_area1):
        return paddle_area1
    if overlaps_area(paddle_area2):
        return paddle_area2
    if overlaps_area(paddle_area3):
        return paddle_area3
    return null

func _process(delta: float) -> void:
    if heart.is_dead():
        return
    _elapsed += delta

    var overlapping_paddle = _get_overlapping_paddle()
    if overlapping_paddle != null:
        sprite.scale.x = paddle.radius / 1000.0
        particles.global_position = overlapping_paddle.global_position
        particles.emitting = true
        var to_center = global_position - overlapping_paddle.global_position
        particles.gravity = to_center.normalized() * 980 
        particles.direction = to_center.normalized()
    else:
        sprite.scale.x = 1.0
        particles.emitting = false

    visible = true if show_pre else _elapsed > charge_time

    if _elapsed > charge_time:
        sprite.scale.y = 1.0
        set_collision_layer_value(1, overlapping_paddle == null)
    else:
        sprite.scale.y = 0.1
        set_collision_layer_value(1, false)

    var t = clampf((_elapsed - charge_time) / (time), 0, 1) if wait_charge else clampf(_elapsed / (time + charge_time), 0, 1)
    rotation = lerpf(curr_angle, next_angle, t)

    if t == 1.0 and not reached:
        target_reached.emit()
        reached = true

func die() -> void:
    queue_free()
    particles.emitting = false
    await get_tree().create_timer(1.5).timeout
    particles.queue_free()

func set_angle(_curr_angle: float, _next_angle: float, _charge_time: float, _time: float, _wait_charge: bool) -> void:
    assert(_time > 0)
    _elapsed = 0.0
    reached = false
    self.curr_angle = _curr_angle
    self.next_angle = _next_angle
    self.charge_time = _charge_time
    self.time = _time
    self.wait_charge = _wait_charge
