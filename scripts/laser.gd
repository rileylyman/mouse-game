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

var particles_scene: PackedScene = preload("res://scenes/laser_particles.tscn")
var particles: GPUParticles2D
var particles_glow: Node2D

@onready var laser_effects: LaserEffects = $"/root/Node2D/LaserEffects"
@onready var paddle: Paddle = $"/root/Node2D/Paddle"
@onready var paddle_area1: Area2D = $"/root/Node2D/Paddle/Paddle/PaddleArea"
@onready var paddle_area2: Area2D = $"/root/Node2D/Paddle/Paddle2/PaddleArea"
@onready var paddle_area3: Area2D = $"/root/Node2D/Paddle/Paddle3/PaddleArea"
@onready var heart: Heart = $"/root/Node2D/Heart"

@onready var sprite_mask: Sprite2D = $LaserMask
@onready var sprite_mask_orig_pos: Vector2 = sprite_mask.position
@onready var sprite_mask_orig_rect: Rect2 = sprite_mask.get_rect()
@onready var sprite: AnimatedSprite2D = $LaserMask/LaserSprite
@onready var sprite_orig_pos: Vector2 = sprite.position
@onready var sprite_orig_scale: Vector2 = sprite.scale
@onready var sprite2: AnimatedSprite2D = $LaserMask/LaserSprite2
@onready var sprite2_orig_pos: Vector2 = sprite2.position
@onready var glow: Sprite2D = $LaserMask/LaserSprite/Glow
@onready var glow_orig_scale: Vector2 = glow.scale
@onready var hit_effect: Node2D = $LaserHitEffect
@onready var hit_effect_orig_pos: Vector2 = hit_effect.position

func _ready() -> void:
    particles = particles_scene.instantiate()
    particles_glow = particles.get_node("Glow")
    particles_glow.scale = Vector2(0.5, 0.5)
    particles.emitting = false
    get_tree().current_scene.add_child(particles)
    rotation = curr_angle
    # scale.x = 1000.0 / 64.0
    # sprite.scale.y = 0.1

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

    GameManager.camera_shake(true)
    var overlapping_paddle = _get_overlapping_paddle()
    if overlapping_paddle != null:
        laser_effects.start_laser()
        # sprite.scale.x = paddle.radius / 1000.0
        var offset = sprite_mask_orig_rect.end.x * sprite_mask.scale.x - paddle.radius
        sprite_mask.position.x = - offset
        var sprite_move = (sprite_mask_orig_pos.x + offset) * 1.0 / sprite_mask.scale.x
        sprite.position.x = sprite_orig_pos.x + sprite_move
        hit_effect.visible = true
        hit_effect.position.x = hit_effect_orig_pos.x + paddle.radius
        sprite2.position.x = sprite2_orig_pos.x + (sprite_mask_orig_pos.x + offset) * 1.0 / sprite_mask.scale.x
        particles.global_position = overlapping_paddle.global_position
        particles.emitting = true
        particles_glow.visible = true
        var to_center = (global_position - overlapping_paddle.global_position).normalized()
        particles.process_material.direction = Vector3(to_center.x, to_center.y, 0.0)
        particles.process_material.gravity = Vector3(to_center.x, to_center.y, 0.0) * 980
        # particles.gravity = to_center.normalized() * 980 
        # particles.direction = to_center.normalized()
        # GameManager.camera_shake(true)
    else:
        hit_effect.visible = false
        laser_effects.stop_laser()
        sprite_mask.position.x = sprite_mask_orig_pos.x 
        sprite.position.x = sprite_orig_pos.x
        sprite2.position.x = sprite2_orig_pos.x
        # sprite.scale.x = 1.0
        particles.emitting = false
        particles_glow.visible = false
        # GameManager.camera_shake(false)

    visible = true if show_pre else _elapsed > charge_time

    if _elapsed > charge_time:
        glow.scale.x = glow_orig_scale.x
        particles_glow.scale = Vector2.ONE
        hit_effect.scale = Vector2.ONE
        sprite.play("big")
        sprite2.play("big")
        set_collision_layer_value(1, overlapping_paddle == null)
    else:
        glow.scale.x = glow_orig_scale.x * 0.5
        particles_glow.scale = Vector2(0.5, 0.5)
        hit_effect.scale = Vector2(0.5, 0.5)
        sprite.play("small")
        sprite2.play("small")
        set_collision_layer_value(1, false)

    var t = clampf((_elapsed - charge_time) / (time), 0, 1) if wait_charge else clampf(_elapsed / (time + charge_time), 0, 1)
    rotation = lerpf(curr_angle, next_angle, t)

    if t == 1.0 and not reached:
        target_reached.emit()
        reached = true

func die() -> void:
    queue_free()
    GameManager.camera_shake(false)
    particles.emitting = false
    particles_glow.visible = false
    laser_effects.stop_laser()
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
