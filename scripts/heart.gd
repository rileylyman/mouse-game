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
    _fast_forward("64:1")
    await _until("1:1")

    _laser(3, 120, 120 -360)
    _laser(3, 240, 240 -360)
    await _laser(3, 0, -360)

    # 8 - 16
    await _until("8:1")

    await _ball_straight(1, 4, -90)
    await _ball_straight(1, 4, 90)

    await _ball_oscillate(2, 8, 2, 0, -180)

    await _ball_straight(1, 4, 90)
    await _ball_straight(1, 4, -90)

    await _ball_oscillate(2, 8, 2, 0, 180)

    # 16 - 24
    await _until("16:1")
    await _ball_straight(1, 4, 0)
    await _ball_straight(1, 4, -180)

    await _ball_alternate(2, 4, 45, 135)
    await _ball_alternate(2, 4, -45, -135)

    await _ball_straight(1, 4, -90)
    await _ball_straight(1, 4, 90)

    # 24 - 32
    await _until("24:1")
    await _ball_oscillate(2, 4, 2, -60, -120)
    await _ball_syncopate1(1, 8, 0, 0, -180)
    await _ball_syncopate1(1, 8, -180, -180, 0)
    await _ball_oscillate(2, 8, 1, 0, 360)
    await _ball_alternate(1, 8, 75, 105)
    await _ball_seq([45, 135, -90], 4)

    # 32 - 40
    await _until("32:1")
    await _laser(2, 0, -360)
    await _ball_straight(1, 4, 0)
    await _ball_syncopate1(1, 8, 0, 0, -180)
    await _ball_straight(1, 8, -90)
    await _ball_straight(1, 8, 90)
    await _ball_oscillate(2, 16, 2, -45, -135)

    # 40 - 48
    await _until("40:1")
    await _ball_alternate(2, 4, -45, -135)
    await _ball_oscillate(1, 8, 1, -45, 45)
    await _ball_alternate(3, 4, 45, 135)
    await _laser(2, 0, 720)

    # 48 - 56
    # talking


    # 56 - 64
    await _until("56:1")

    _rotate_frame(4, 0, 360 * 3)
    await _ball_seq([0, null, 0, null, 0, 0, null, 0, null, 0, null, 0, 0, 0, 0, 0], 8, 2)

    await _ball_syncopate1(2, 8, 0, 0, -180)

    await _ball_oscillate(1, 8, 1, 180, 0)

    await _ball_seq([-45, -90, -135], 4)

    # 64 - 72
    await _until("64:1")

    await _laser(2, 0, 360)
    await _ball_alternate2(2, 8, 30, -30)
    await _ball_syncopate1(2, 8, 0, 0, -180)
    await _ball_syncopate1(2, 16, 0, 15, -15)

    # 72 - 80
    await _until("72:1")

    await _rest_bars(6)
    await _ball_oscillate(2, 16, 1, 0, 360)


func _ball_alternate2(bars: int, on: int, deg1: float, deg2: float) -> void:
    var fn = func():
        await _ball_seq([deg1, deg1, deg2, deg2], on, bars * int(on / 4.0))
    fn.call()
    await _rest_bars(bars)

func _ball_alternate(bars: int, on: int, deg1: float, deg2: float) -> void:
    var fn = func():
        await _ball_seq([deg1, deg2, deg1, deg2], on, bars * int(on / 4.0))
    fn.call()
    await _rest_bars(bars)

func _ball_syncopate1(bars: int, on: int, deg1: float, deg2: float, deg3: float) -> void:
    var fn = func():
        await _ball_seq([deg1, deg2, deg3, null], on, bars * int(on / 4.0))
    fn.call()
    await _rest_bars(bars)

func _ball_syncopate2(bars: int, on: int, deg1: float, deg2: float, deg3: float) -> void:
    var fn = func():
        await _ball_seq([deg1, deg2, null, deg3], on, bars * int(on / 4.0))
    fn.call()
    await _rest_bars(bars)

func _ball_straight(bars: int, on: int, deg: float) -> void:
    var fn = func():
        await _ball_seq([deg, deg, deg, deg], on, bars * int(on / 4.0))
    fn.call()
    await _rest_bars(bars)

func _ball_seq(seq: Array, on: int, repeat: int = 1) -> void:
    for i in repeat:
        for deg in seq:
            if deg != null:
                _spawn_ball(deg)
            await BeatManager.wait(on, 1)

func _ball_oscillate(bars: int, on: int, periods: int, deg1: float, deg2: float, repeats: int = 1) -> void:
    var fn = func():
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
    fn.call()
    await _rest_bars(bars * repeats)

func _rest_bars(bars: int, sixteens: int = -HeartBall.take_sixteenths) -> void:
    await BeatManager.wait_for_bar("%d:1" % (int(BeatManager.curr_sixteenth / 16.0) + 1 + bars), sixteens)

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

func _rotate_frame(bars: int, from: float, to: float) -> void:
    frame_rotation = from
    var count = bars * 16
    var step = (to - from) / count
    for i in count:
        frame_rotation += step
        await BeatManager.wait(16, 1)
    frame_rotation = 0


func _laser(bars: int, from: float, to: float, charge_interval: int = 8, wait_charge: bool = false) -> void:
    var fn = func():
        await _rest_bars(0, 0)
        var laser = _spawn_laser(from)
        var charge_time = BeatManager.secs_per_beat * charge_interval / 4
        laser.set_angle(deg_to_rad(from), deg_to_rad(to), charge_time, BeatManager.secs_per_beat * bars * 4 - charge_time, wait_charge)
        await laser.target_reached
        laser.die()
    fn.call()
    await _rest_bars(bars)

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
