class_name Heart extends Node2D


@onready var beat: Node2D = $HeartOutBeat
@onready var heart_in: Sprite2D = $HeartIn
@onready var original_scale: Vector2 = scale
@onready var bubble = %SpeechBubble

@onready var heart_in_offset_y: float = heart_in.offset.y
@onready var heart_in_region_y: float = heart_in.region_rect.position.y
@onready var heart_in_region_h: float = heart_in.region_rect.size.y

var frame_rotation: float = 0.0

var heart_ball_scene: PackedScene = preload("res://scenes/heart_ball.tscn")
var laser_scene: PackedScene = preload("res://scenes/laser.tscn")

func _ready() -> void:
    _beat_anim_async()
    _run_heart_seq_async()
    _run_text_seq_async()

# func _process(delta: float) -> void:
#     frame_rotation += delta * 5

func _set_heart_in_t(t: float) -> void:
    heart_in.offset.y = heart_in_offset_y + heart_in_region_h * (1.0 - t)
    heart_in.region_rect.position.y = heart_in_region_y + heart_in_region_h * (1.0 - t)

func _run_text_seq_async() -> void:
    await BeatManager.next_bar
    await _set_text("ok, i'll let you be my bodyguard", 48)
    await _set_text("but honestly, they need your protection more than me", 48)
    await _set_text("here they come", 48)

func _fast_forward(s: String) -> void:
    BeatManager.fast_forward = true
    await _until(s)
    BeatManager.fast_forward = false

func _run_heart_seq_async() -> void:
    SoundEffects.play_ball_burst()
    # _fast_forward("67:1")

    # 0-8: Talking
    # _fast_forward("32:1")
    await _until("1:1")

    _laser(3, 120, 120 -360)
    _laser(3, 240, 240 -360)
    await _laser(3, 0, -360)


    return
    # 8-12: Card. dir. shoots
    await _until("8:1")
    await _ball_seq([-90], 4, 4)
    await _ball_seq([180], 4, 4)
    await _ball_seq([90], 4, 4)
    await _ball_seq([0], 4, 4)

    # 12-16: Rotations
    await _until("12:1")
    await _ball_sweep(0, -180, 4, 4)
    await _ball_sweep(-180, 0, 4, 4)
    await _ball_sweep(0, 360, 8, 8)
    await _ball_sweep(0, 360, 8, 8)

    # 16-20: Card. dir. shoots
    await _until("16:1")
    await _ball_seq([-90], 4, 4)
    await _ball_seq([180], 4, 4)
    await _ball_seq([90], 8, 8)
    await _ball_seq([0], 8, 8)

    # 20-22: Back + forth
    await _until("20:1")
    await _ball_seq([0, null, -180, -180], 8, 4)

    await _ball_seq([90], 2, 2)
    await _ball_seq([-90], 2, 2)

    await _until("24:1")
    await _ball_sweep(0, -180, 4, 8)
    await _ball_sweep(-180, 0, 4, 8)
    await _ball_sweep(0, 180, 8, 16)
    await _ball_sweep(180, 0, 8, 16)

    await _ball_sweep(0, 360, 16, 16)

    await _until("32:1")
    await _ball_sweep(-45, -45, 8, 8)
    await _ball_sweep(-135, -135, 8, 8)
    await _ball_sweep(0, 360, 8, 32)
    await _ball_sweep(0, -360, 8, 32)

    # 40 lasers
    await _until("40:1")
    _ball_sweep(45, 45, 2, 32)
    await _until("40:2")
    _ball_sweep(135, 135, 2, 32)
    await _until("42:1")
    _ball_sweep(-45, -45, 2, 32)
    await _until("42:2")
    _ball_sweep(-135, -135, 2, 32)
    await _until("44:1")
    await _laser(0, -360, 8, 32, false)
    await _laser(0, 360, 0, 32, false)

    await _until("56:1")
    await _ball_sweep(-90, -90, 4, 16)
    await _ball_sweep(180, 180, 4, 16)
    await _ball_sweep(90, 90, 4, 16)
    await _ball_sweep(0, 0, 4, 16)

    await _until("60:1")
    _ball_sweep(45, 45, 2, 32)
    await _until("60:2")
    _ball_sweep(135, 135, 2, 32)
    await _until("62:1")
    _ball_sweep(-45, -45, 2, 32)
    await _until("62:2")
    _ball_sweep(-135, -135, 2, 32)

    await _until("64:1")
    await _laser(0, 360, 4, 32, false)
    _laser(0, 360, 0, 28, false)

    await _until("68:1")
    await _ball_sweep(0, 0, 8, 4)
    await _ball_sweep(-180, -180, 8, 2)
    await _until("68:3")
    await _ball_sweep(0, 0, 8, 4)
    await _ball_sweep(-180, -180, 8, 2)
    await _until("69:1")
    await _ball_sweep(0, 0, 8, 4)
    await _ball_sweep(180, 180, 8, 2)
    await _until("69:3")
    await _ball_sweep(0, 0, 8, 4)
    await _ball_sweep(180, 180, 8, 2)
    await _until("70:1")
    await _ball_sweep(0, 0, 8, 4)
    await _ball_sweep(-180, -180, 8, 2)
    await _until("70:3")
    await _ball_sweep(0, 0, 8, 4)
    await _ball_sweep(-180, -180, 8, 2)
    await _until("71:1")
    await _ball_sweep(0, 0, 8, 4)
    await _ball_sweep(180, 180, 8, 2)
    await _until("71:3")
    await _ball_sweep(0, 0, 8, 4)
    await _ball_sweep(180, 180, 8, 2)

    await _until("72:1")
    await _ball_sweep(-180, 180, 8, 32)
    await _ball_sweep(-180, 180, 16, 32)

func _ball_alternate(bars: int, on: int, deg1: float, deg2: float) -> void:
    await _ball_seq([deg1, deg2, deg1, deg2], on, bars * int(on / 4.0))

func _ball_syncopate1(bars: int, on: int, deg1: float, deg2: float, deg3: float) -> void:
    await _ball_seq([deg1, deg2, deg3, null], on, bars * int(on / 4.0))

func _ball_syncopate2(bars: int, on: int, deg1: float, deg2: float, deg3: float) -> void:
    await _ball_seq([deg1, deg2, null, deg3], on, bars * int(on / 4.0))

func _ball_straight(bars: int, on: int, deg: float) -> void:
    await _ball_seq([deg, deg, deg, deg], on, bars * int(on / 4.0))

func _ball_seq(seq: Array, on: int, repeat: int = 1) -> void:
    for i in repeat:
        for deg in seq:
            if deg != null:
                _spawn_ball(deg)
            await BeatManager.wait(on, 1)

func _ball_oscillate(bars: int, on: int, periods: int, deg1: float, deg2: float, repeats: int = 1) -> void:
    for i in repeats:
        var count = int(bars * on / float(periods))
        var angle = deg1
        var step = (deg2 - deg1) / count
        for j in range(periods):
            for k in range(count):
                _spawn_ball(angle)
                angle += step
                await BeatManager.wait(on, 1)
            step *= -1

func _ball_sweep(bars: int, on: int, from: float, to: float) -> void:
    var count = bars * on
    var angle = from
    var step: float = (to - from) / count
    for i in range(count):
        _spawn_ball(angle)
        angle += step
        await BeatManager.wait(on, 1)

func _rest_bars(bars: int) -> void:
    await BeatManager.wait_for_bar("%d:1" % (int(BeatManager.curr_sixteenth / 16.0) + 1 + bars), -HeartBall.take_sixteenths)


func _until(s: String) -> void:
    await BeatManager.wait_for_bar(s, -HeartBall.take_sixteenths)

func _set_text(s: String, sixteens: int) -> void:
    var curr_len = 0
    var end = BeatManager.curr_sixteenth + sixteens
    while BeatManager.curr_sixteenth < end:
        bubble.text = s.substr(0, curr_len)
        await get_tree().create_timer(BeatManager.secs_per_sixteenth / 2).timeout
        curr_len += 1
    bubble.text = ""


func _laser(bars: int, from: float, to: float, charge_interval: int = 8, wait_charge: bool = false) -> void:
    if charge_interval == -1:
        charge_interval = 4 * bars
    var laser = _spawn_laser(from)
    laser.set_angle(deg_to_rad(from), deg_to_rad(to), BeatManager.secs_per_beat * charge_interval / 4, BeatManager.secs_per_beat * bars * 4, wait_charge)
    await laser.target_reached
    laser.die()

func _spawn_laser(deg: float) -> Laser:
    var laser: Laser = laser_scene.instantiate()
    laser.global_position = global_position
    laser.curr_angle = deg_to_rad(deg)
    get_tree().current_scene.add_child.call_deferred(laser)
    return laser

func _spawn_ball(deg: float) -> void:
    var ball: HeartBall = heart_ball_scene.instantiate()
    ball.global_position = global_position
    ball.dir = Vector2.RIGHT.rotated(deg_to_rad(deg + frame_rotation))
    ball.speed = 100.0
    ball.check_on_sixteenth = BeatManager.curr_sixteenth + HeartBall.take_sixteenths
    get_tree().current_scene.add_child.call_deferred(ball)

func _beat_anim_async() -> void:
    beat.visible = false
    while true:
        await BeatManager.next_4
        beat.visible = true
        scale = original_scale * 1.25
        await BeatManager.next_4
        beat.visible = false
        scale = original_scale
