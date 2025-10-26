class_name Heart extends Node2D


@onready var beat: Node2D = $HeartOutBeat
@onready var heart_in: Sprite2D = $HeartIn
@onready var original_scale: Vector2 = scale

@onready var heart_in_offset_y: float = heart_in.offset.y
@onready var heart_in_region_y: float = heart_in.region_rect.position.y
@onready var heart_in_region_h: float = heart_in.region_rect.size.y

var heart_ball_scene: PackedScene = preload("res://scenes/heart_ball.tscn")
var laser_scene: PackedScene = preload("res://scenes/laser.tscn")

func _ready() -> void:
    _beat_anim_async()
    _run_heart_seq_async()

func _set_heart_in_t(t: float) -> void:
    heart_in.offset.y = heart_in_offset_y + heart_in_region_h * (1.0 - t)
    heart_in.region_rect.position.y = heart_in_region_y + heart_in_region_h * (1.0 - t)

func _run_heart_seq_async() -> void:
    await BeatManager.next_bar
    await _sweep_laser(0, 180, 8, 24, true)
    await BeatManager.next_bar
    await _sweep_laser(0, -180, 8, 24, false)
    await BeatManager.next_bar
    await _sweep_balls(0, 180, 8, 4)
    await BeatManager.next_bar
    await _sweep_balls(0, -180, 8, 8)
    await BeatManager.next_bar
    await _sweep_laser(0, 180, 8, 24, true)
    await BeatManager.next_bar
    await _sweep_laser(0, -180, 8, 24, false)
    await BeatManager.next_bar

func _sweep_laser(from: float, to: float, charge_interval: int, sixteens: int, wait_charge: bool) -> void:
    var laser = _spawn_laser(from)
    laser.set_angle(deg_to_rad(from), deg_to_rad(to), BeatManager.secs_per_beat * charge_interval / 4, BeatManager.secs_per_beat * sixteens / 4, wait_charge)
    await laser.target_reached
    laser.die()


func _sweep_balls(from: float, to: float, count: int, sixteens: int) -> void:
    var angle = from
    var step: float = (to - from) / count
    while angle <= to if to > from else angle >= to:
        _spawn_ball(angle)
        angle += step
        await get_tree().create_timer(BeatManager.secs_per_beat * 4 / sixteens).timeout

func _spawn_laser(deg: float) -> Laser:
    var laser: Laser = laser_scene.instantiate()
    laser.global_position = global_position
    laser.curr_angle = deg_to_rad(deg)
    get_tree().current_scene.add_child.call_deferred(laser)
    return laser

func _spawn_ball(deg: float) -> void:
    var ball: HeartBall = heart_ball_scene.instantiate()
    ball.global_position = global_position
    ball.dir = Vector2.RIGHT.rotated(deg_to_rad(deg))
    ball.speed = 100.0
    get_tree().current_scene.add_child.call_deferred(ball)

func _beat_anim_async() -> void:
    beat.visible = false
    while true:
        await BeatManager.wait(16, 6)
        beat.visible = true
        scale = original_scale * 1.25
        await BeatManager.wait(16, 2)
        beat.visible = false
        scale = original_scale
