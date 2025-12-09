class_name Heart extends Node2D

@onready var viscont: Node2D = $VisualContainer
@onready var beat: Node2D = $VisualContainer/HeartOutBeat
@onready var heart_in: Sprite2D = $VisualContainer/HeartIn
@onready var original_scale: Vector2 = scale
@onready var bubble = %SpeechBubble
@onready var heart_proj_cont: Node2D = $"/root/Node2D/HeartProjectileContainer"
@onready var paddle = %Paddle
@onready var text_blips = %TextBlips
@onready var laser_effects: LaserEffects = %LaserEffects

@onready var heart_in_offset_y: float = heart_in.offset.y
@onready var heart_in_region_y: float = heart_in.region_rect.position.y
@onready var heart_in_region_h: float = heart_in.region_rect.size.y

var max_health: int = 30 
var health: int = max_health

var frame_rotation: float = 0.0
var triple: bool = false

var heart_ball_scene: PackedScene = preload("res://scenes/heart_ball.tscn")
var heart_ball_big_scene: PackedScene = preload("res://scenes/heart_ball_big.tscn")
var laser_scene: PackedScene = preload("res://scenes/laser.tscn")

func take_damage() -> void:
    if Engine.time_scale != 1.0:
        return
    health -= 1
    health = max(0, health)
    _set_heart_in_t(float(health) / max_health)

func is_dead() -> bool:
    return health == 0

func _ready() -> void:
    _beat_anim_async()
    _run_heart_seq_async()

func _set_heart_in_t(t: float) -> void:
    heart_in.offset.y = heart_in_offset_y + heart_in_region_h * (1.0 - t)
    heart_in.region_rect.position.y = heart_in_region_y + heart_in_region_h * (1.0 - t)

func _fast_forward(s: String) -> void:
    BeatManager.fast_forward = true
    await _until(s)
    BeatManager.fast_forward = false

func _run_heart_seq_async() -> void:
    _fast_forward("80:1")

    # await BeatManager.click_signal
    # await BeatManager.start_signal
    # await _laser(32, 0, -360 * 10)

    await BeatManager.click_signal

    await _set_text(2, "I keep hurting people")
    _set_text(2, "Maybe you can help me")

    await BeatManager.start_signal

    await _set_text(2, "See them?")
    await _set_text(2, "Protect them")
    await _set_text(2, "Keep my energy from hitting them")
    _set_text(2, "Follow the rhythm")

    # 8 - 16
    await _until("8:1")

    await _ball_straight(1, 4, -90)
    await _ball_straight(1, 4, 90)

    await _ball_oscillate(2, 8, 2, 0, -180)

    await _ball_straight(1, 4, 90)
    await _ball_straight(1, 4, -90, true)

    await _ball_oscillate(2, 8, 2, 0, 180)

    # 16 - 24
    await _until("16:1")
    await _ball_straight(1, 4, 0)
    await _ball_straight(1, 4, -180)

    await _ball_alternate(2, 4, 45, 135)
    await _ball_alternate(2, 4, -45, -135)

    await _ball_straight(1, 4, -90)
    await _ball_straight(1, 4, 90, true)

    # 24 - 32
    await _until("24:1")
    await _ball_oscillate(2, 4, 2, -60, -120)
    await _ball_syncopate1(2, 8, 0, 0, -180)
    await _ball_oscillate(2, 8, 1, 0, 360)
    await _ball_alternate(1, 8, 75, 105)
    await _ball_seq([45, 135, -90], 4, true)

    # 32 - 40
    await _until("32:1")
    await _laser(2, 0, -360)
    await _ball_straight(1, 4, 0)
    await _ball_syncopate1(1, 8, 0, 0, -180)
    await _ball_straight(1, 8, -90)
    await _ball_straight(1, 8, 90)
    await _ball_oscillate(2, 16, 2, -45, -135, true)

    # 40 - 48
    await _until("40:1")
    await _ball_alternate(2, 4, -45, -135, true)
    await _ball_oscillate(1, 8, 1, -45, 45, 1, true)
    await _ball_alternate(1, 4, 45, 135, true)
    await _ball_alternate(2, 4, 45, 135)
    await _laser(2, 0, 720)

    # 48 - 56
    # talking

    await _until("48:1")
    var text_async = func():
        await _until("48:3")
        if health < max_health / 2.0:
            await _set_text(2, "Things got pretty dicey back there")
        else:
            await _set_text(2, "Wow, you're doing a great job")
        await _set_text(2, "But it's going to get a bit tougher")
        await _set_text(2, "Keep it up!")
    text_async.call()

    # 56 - 64
    await _until("56:1")

    _rotate_frame(4, 0, 360 * 2)
    await _ball_seq([0, null, 0, null, 0, 0, null, 0, null, 0, null, 0, 0, 0, 0, 0], 8, 2)

    await _ball_syncopate1(2, 8, 0, 0, -180)

    await _ball_oscillate(1, 8, 1, 180, 0)

    await _ball_seq([-45, -90, -135], 4, true)

    # 64 - 72
    await _until("64:1")

    await _laser(2, 0, 360)
    await _ball_alternate2(2, 8, 30, -30)
    await _ball_syncopate1(2, 8, 0, 0, -180)
    _rotate_frame(2, -90, 0)
    await _ball_syncopate1(2, 16, 0, 15, -15)

    # 72 - 80
    await _until("72:1")

    _rotate_frame(4, 0, 360 * 3)
    await _ball_seq([0, null, 0, null, 0, 0, null, 0, null, 0, null, 0, 0, 0, 0, 0], 8, 2, true)
    await _ball_oscillate(2, 16, 1, 0, 360)
    await _laser(2, 0, -180)

    # 80 - 88
    await _until("80:1")
    await _rest_bars(1)
    await _ball_oscillate(1, 4, 1, 0, 360, 1, true)
    await _ball_oscillate(2, 8, 1, 0, 720)
    _rotate_frame(4, 0, 360 * 5)
    await _ball_seq([0, null, 0, null, 0, 0, null, 0, null, 0, null, 0, 0, 0, 0, 0], 8, 2, true)

    # 88 - 96
    await _until("88:1")
    _rotate_frame(4, 0, 360)
    await _ball_alternate2(4, 8, 0, 45)
    await _laser(2, 0, 720)
    await _ball_oscillate(2, 4, 4, 45, 135, true)

    # 96 - 104
    await _until("96:1")
    await _laser(1, -180, 180)
    await _ball_oscillate(1, 8, 1, -180, 0)
    await _laser(1, 0, 360)
    await _ball_oscillate(1, 16, 1, 0, -180)
    await _laser(1, -180, 0)
    await _ball_alternate(1, 16, 15, -15)
    _rotate_frame(2, 0, 720)
    await _ball_seq([0, null, 0, null, 0, 0, null, 0, null, 0, null, 0, 0, 0, 0, 0], 8, true)

    # 104 - 112
    await _until("104:1")
    await _laser(1, 0, 360)
    await _ball_oscillate(1, 8, 1, 0, -180)
    await _laser(1, -180, 180)
    await _ball_oscillate(1, 16, 1, -180, 0)
    await _laser(1, 0, -180)
    await _ball_alternate(1, 16, 15 - 180, -15 - 180)
    frame_rotation = -180
    _rotate_frame(2, -180, 720 - 180)
    await _ball_seq([0, null, 0, null, 0, 0, null, 0, null, 0, null, 0, 0, 0, 0, 0], 8, true)
    frame_rotation = 0

    # 112 - 120
    await _until("112:1")
    text_async = func():
        await _until("114:1")
        await _set_text(2, "Yeah!! Feel the groove!")
        await _set_text(2, "I can feel myself cooling down")
        await _set_text(2, "Just a bit longer.")
    text_async.call()
    await _ball_oscillate(8, 1, 1, 0, 360 * 4)

    # 120 - 128
    await _until("120:1")
    text_async = func():
        await _until("122:1")
        await _set_text(2, "Wait...")
        await _set_text(2, "I feel a bit strange.")
        await _set_text(2, "I'm sorry...")
    text_async.call()
    await _ball_oscillate(4, 2, 1, 0, 360 * 2)
    await _ball_oscillate(2, 4, 1, 0, 360, 1, true)
    await _ball_oscillate(1, 8, 1, 0, 180, 1, true)
    await _ball_oscillate(1, 16, 1, 180, 360, 1, true)

    # 128 - 136
    triple = true
    paddle.triple = true
    await _until("128:1")
    await _laser(4, 0, 360)
    await _ball_straight(1, 8, 0)
    await _ball_straight(1, 8, -90)
    await _ball_straight(1, 8, -180)
    await _ball_straight(1, 8, 90)

    # 136 - 144
    await _until("136:1")
    await _laser(4, 0, -360)
    await _ball_straight(1, 8, 90, true)
    await _ball_straight(1, 8, -180)
    await _ball_straight(1, 8, -90, true)
    await _ball_straight(1, 8, 0)

    # 144 - 152
    await _until("144:1")
    await _ball_oscillate(8, 16, 4, 0, -180)
    triple = false

    # 152 - 160
    await _until("152:1")
    var disable_paddle = func():
        await BeatManager.next_bar
        paddle.triple = false
    disable_paddle.call()
    _rotate_frame(8, 0, -720 * 3)
    await _ball_seq([0, 0, 0, null, 0, null, 0, 0, 0, 0, 0, 0, 0, 0, 0, null], 8, 1, true)
    await _ball_seq([0, null, 0, null, 0, null, null, 0, 0, 0, 0, 0, 0, 0, 0, 0], 8, 1, true)
    _crt_async_change()
    await _ball_seq([0, 0, 0, null, 0, null, 0, 0, 0, 0, 0, 0, 0, 0, 0, null], 8, 1, true)
    await _ball_seq([0, null, 0, null, 0, null, null, 0], 8, 1, true)


func _crt_async_change() -> void:
    var mat: ShaderMaterial = flowerwall_crt.crt.get_child(0).material
    var wiggle_orig = mat.get_shader_parameter("wiggle")
    var wiggle_max = 0.5
    var chroma_orig = mat.get_shader_parameter("chromatic_aberration_strength")
    var chroma_max = 10.0
    var vignette_orig = mat.get_shader_parameter("vignette_size")
    var vignette_max = 100.0
    
    var slider = 0.0
    while slider < 1.0:
        await get_tree().create_timer(0.1).timeout
        slider += 0.0075
        flowerwall_crt._on_vhs_wiggle_strength_slider_value_changed(lerpf(wiggle_orig, wiggle_max, slider))
        flowerwall_crt._on_chroma_aberr_strength_slider_value_changed(lerpf(chroma_orig, chroma_max, slider))
        flowerwall_crt._on_vignette_size_slider_value_changed(lerpf(vignette_orig, vignette_max, slider * slider * slider))

    await get_tree().create_timer(5.0).timeout
    GameManager.quit()


func _ball_alternate2(bars: int, on: int, deg1: float, deg2: float, big: bool = false) -> void:
    var fn = func():
        await _ball_seq([deg1, deg1, deg2, deg2], on, bars * int(on / 4.0), big)
    fn.call()
    await _rest_bars(bars)

func _ball_alternate(bars: int, on: int, deg1: float, deg2: float, big: bool = false) -> void:
    var fn = func():
        await _ball_seq([deg1, deg2, deg1, deg2], on, bars * int(on / 4.0), big)
    fn.call()
    await _rest_bars(bars)

func _ball_syncopate1(bars: int, on: int, deg1: float, deg2: float, deg3: float, big: bool = false) -> void:
    var fn = func():
        await _ball_seq([deg1, deg2, deg3, null], on, bars * int(on / 4.0), big)
    fn.call()
    await _rest_bars(bars)

func _ball_syncopate2(bars: int, on: int, deg1: float, deg2: float, deg3: float, big: bool = false) -> void:
    var fn = func():
        await _ball_seq([deg1, deg2, null, deg3], on, bars * int(on / 4.0), big)
    fn.call()
    await _rest_bars(bars)

func _ball_straight(bars: int, on: int, deg: float, big: bool = false) -> void:
    var fn = func():
        await _ball_seq([deg, deg, deg, deg], on, bars * int(on / 4.0), big)
    fn.call()
    await _rest_bars(bars)

func _ball_seq(seq: Array, on: int, repeat: int = 1, big: bool = false) -> void:
    for i in repeat:
        for deg in seq:
            if deg != null:
                _spawn_ball(deg, big)
            await BeatManager.wait(on, 1)

func _ball_oscillate(bars: int, on: int, periods: int, deg1: float, deg2: float, repeats: int = 1, big: bool = false) -> void:
    var fn = func():
        for i in repeats:
            var count = int(bars * on / float(periods))
            var angle = deg1
            var step = (deg2 - deg1) / count
            for j in range(periods):
                for k in range(count):
                    _spawn_ball(angle, big)
                    angle += step
                    await BeatManager.wait(on, 1)
                step *= -1
    fn.call()
    await _rest_bars(bars * repeats)

func _rest_bars(bars: int, sixteens: int = -HeartBall.take_sixteenths) -> void:
    await BeatManager.wait_for_bar("%d:1" % (int(BeatManager.curr_sixteenth / 16.0) + 1 + bars), sixteens)

func _until(s: String) -> void:
    await BeatManager.wait_for_bar(s, -HeartBall.take_sixteenths)

func _set_text(bars: int, s: String) -> void:
    text_blips.play()
    var stopped = false
    var curr_len = 0
    var end = GameManager.time_s + BeatManager.secs_per_beat * 4 * bars
    while GameManager.time_s < end:
        bubble.text = s.substr(0, curr_len)
        await get_tree().create_timer(BeatManager.secs_per_sixteenth / 2).timeout
        if curr_len >= s.length():
            if not stopped:
                text_blips.stop()
                stopped = true
        else:
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


func _laser(bars: int, from: float, to: float) -> void:
    if triple:
        _laser_internal(bars, from, to)
        _laser_internal(bars, from + 120, to + 120)
        await _laser_internal(bars, from - 120, to - 120)
    else:
        await _laser_internal(bars, from, to)

func _laser_internal(bars: int, from: float, to: float) -> void:
    if is_dead():
        await get_tree().create_timer(10.0).timeout
    var fn = func():
        await BeatManager.next_bar
        # laser_effects.start_laser()
        var laser = _spawn_laser(from)
        var charge_time = HeartBall.take_sixteenths * BeatManager.secs_per_beat / 4
        laser.set_angle(deg_to_rad(from), deg_to_rad(to), charge_time, BeatManager.secs_per_beat * bars * 4 - charge_time, false)
        laser.show_pre = true
        await laser.target_reached
        laser.die()
        # laser_effects.stop_laser()
    fn.call()
    await _rest_bars(bars)

func _spawn_laser(deg: float) -> Laser:
    var laser: Laser = laser_scene.instantiate()
    laser.global_position = global_position
    laser.curr_angle = deg_to_rad(deg)
    heart_proj_cont.add_child.call_deferred(laser)
    return laser

func _spawn_ball(deg: float, big: bool) -> void:
    _spawn_ball_internal(deg, big)
    if triple:
        _spawn_ball_internal(deg + 120, big)
        _spawn_ball_internal(deg - 120, big)

func _spawn_ball_internal(deg: float, big: bool) -> void:
    if is_dead():
        await get_tree().create_timer(10.0).timeout
    var ball: HeartBall = heart_ball_scene.instantiate() if not big else heart_ball_big_scene.instantiate()
    ball.dir = Vector2.RIGHT.rotated(deg_to_rad(deg + frame_rotation))
    ball.speed = 100.0
    ball.check_on_sixteenth = BeatManager.curr_sixteenth + HeartBall.take_sixteenths
    heart_proj_cont.add_child.call_deferred(ball)

func _beat_anim_async() -> void:
    beat.visible = false
    while not is_dead():
        await BeatManager.next_4
        beat.visible = not beat.visible
        scale = original_scale if scale.length() > original_scale.length() else original_scale * 1.25
