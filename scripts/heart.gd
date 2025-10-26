class_name Heart extends Node2D


@onready var beat: Node2D = $HeartOutBeat
@onready var heart_in: Sprite2D = $HeartIn
@onready var original_scale: Vector2 = scale
@onready var bubble = %SpeechBubble

@onready var heart_in_offset_y: float = heart_in.offset.y
@onready var heart_in_region_y: float = heart_in.region_rect.position.y
@onready var heart_in_region_h: float = heart_in.region_rect.size.y

var heart_ball_scene: PackedScene = preload("res://scenes/heart_ball.tscn")
var laser_scene: PackedScene = preload("res://scenes/laser.tscn")

func _ready() -> void:
    _beat_anim_async()
    _run_heart_seq_async()
    _run_text_seq_async()

func _set_heart_in_t(t: float) -> void:
    heart_in.offset.y = heart_in_offset_y + heart_in_region_h * (1.0 - t)
    heart_in.region_rect.position.y = heart_in_region_y + heart_in_region_h * (1.0 - t)

func _run_text_seq_async() -> void:
    await BeatManager.next_bar
    await _set_text("ok, i'll let you be my bodyguard", 48)
    await _set_text("but honestly, they need your protection more than me", 48)
    await _set_text("here they come", 48)

func _fast_forward(bar: int) -> void:
    BeatManager.fast_forward = true
    await _until(bar)
    BeatManager.fast_forward = false

func _run_heart_seq_async() -> void:
    SoundEffects.play_ball_burst()
    _fast_forward(8)

    await _until(1)
    await _balls(0, 0, 16, 16)
    await _balls(-180, -180, 16, 16)

    await _until(8)
    await _balls(0, -180, 4, 16)
    await _until(9)
    await _balls(0, -180, 8, 16)

    await _until(26)

    await _balls(-45, -45, 4, 16)
    await _balls(-135, -135, 4, 16)
    await _balls(45, 45, 8, 16)
    await _balls(135, 135, 8, 16)

    await _until(32)
    await _balls(-45, -45, 8, 8)
    await _balls(-135, -135, 8, 8)
    await _balls(0, 360, 8, 32)
    await _balls(0, -360, 8, 32)

func _until(bar: int) -> void:
    await BeatManager.wait_for_bar(bar, -HeartBall.take_sixteenths)

func _set_text(s: String, sixteens: int) -> void:
    var curr_len = 0
    var end = BeatManager.curr_sixteenth + sixteens
    while BeatManager.curr_sixteenth < end:
        bubble.text = s.substr(0, curr_len)
        await get_tree().create_timer(BeatManager.secs_per_sixteenth / 2).timeout
        curr_len += 1
    bubble.text = ""


func _laser(from: float, to: float, charge_interval: int, sixteens: int, wait_charge: bool) -> void:
    var laser = _spawn_laser(from)
    laser.set_angle(deg_to_rad(from), deg_to_rad(to), BeatManager.secs_per_beat * charge_interval / 4, BeatManager.secs_per_beat * sixteens / 4, wait_charge)
    await laser.target_reached
    laser.die()

func _balls(from: float, to: float, on: int, sixteens: int) -> void:
    var count = sixteens * (float(on) / 16)
    var angle = from
    var step: float = (to - from) / (count)
    for i in range(count):
        _spawn_ball(angle)
        angle += step
        await BeatManager.wait(16, int(16.0 / on))
        # await get_tree().create_timer(BeatManager.secs_per_beat * 4 / on).timeout

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
    ball.check_on_sixteenth = BeatManager.curr_sixteenth + HeartBall.take_sixteenths
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
