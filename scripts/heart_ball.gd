class_name HeartBall extends Area2D

@export var is_big: bool

var dir: Vector2
var speed: float = 100.0
var dead = false

static var take_sixteenths: int = 8 
var check_on_sixteenth: int = 0

var touched_paddle = false

@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var paddle: Paddle = $"/root/Node2D/Paddle"
@onready var paddle_area1: Area2D = $"/root/Node2D/Paddle/Paddle/PaddleArea"
@onready var paddle_area2: Area2D = $"/root/Node2D/Paddle/Paddle2/PaddleArea"
@onready var paddle_area3: Area2D = $"/root/Node2D/Paddle/Paddle3/PaddleArea"

@onready var sprite_container: Node2D = $SpriteContainer
@onready var sprite: AnimatedSprite2D = $SpriteContainer/AnimatedSprite2D
@onready var explosion: AnimatedSprite2D = $SpriteContainer/Explosion

func _ready() -> void:
    dir = dir.normalized()
    var total_time = (check_on_sixteenth - BeatManager.curr_sixteenth) * BeatManager.secs_per_beat / 4
    speed = paddle.radius / total_time
    global_scale = Vector2.ONE
    global_rotation = 0
    global_position = heart.global_position

    area_entered.connect(_on_area_enter)

    _check_on(check_on_sixteenth - 1)
    _check_on(check_on_sixteenth)

    sprite_container.rotation = -dir.angle_to(Vector2.UP)
    sprite_container.scale = Vector2(2, 0.75) if is_big else Vector2(4, 0.5)
    var tween_time := 0.25
    var tween_time2 := 0.25
    var tween = create_tween()
    tween.parallel().tween_property(sprite_container, "scale:x", 0.75, tween_time)
    tween.parallel().tween_property(sprite_container, "scale:y", 1.25, tween_time)
    tween.tween_property(sprite_container, "scale", Vector2(0.9, 1.1), tween_time2)

func _check_on(on: int) -> void:
    await BeatManager.wait_for_sixteenth(on)
    if heart.is_dead():
        return
    _check_paddle(paddle_area1)
    if heart.triple:
        _check_paddle(paddle_area2)
        _check_paddle(paddle_area3)

func _check_paddle(_paddle_area: Area2D) -> void:
    # var bv = global_position - heart.global_position
    # var pv = paddle_area.global_position - heart.global_position
    # if abs(bv.normalized().angle_to(pv.normalized())) < paddle.arc_deg / 2 + deg_to_rad(5.0):
    #     die()
    if touched_paddle:
        paddle.shake_paddles()
        die()

func _process(delta: float) -> void:
    if heart.is_dead():
        return
    global_position += dir * speed * delta

    var r = global_position.distance_to(heart.global_position)
    if r > 4000.0:
        queue_free()

func _on_area_enter(area: Area2D) -> void:
    if area.name == "PaddleArea":
        touched_paddle = true
        death_anim()

var played_death_anim := false
func death_anim() -> void:
    if played_death_anim:
        return
    played_death_anim = true
    speed = 0


    # sprite_container.modulate = Color.hex(0xff004e)
    # sprite_container.modulate = Color.RED
    # var tween = create_tween()
    # tween.tween_property(sprite_container, "scale", Vector2(2, 0.25), 0.05)
    # tween.tween_property(sprite_container, "scale", Vector2(1.5, 0.5), 0.025)
    # tween.tween_callback(sprite_container.queue_free)
    sprite.visible = false
    explosion.play("default")

func die() -> void:
    if dead:
        return
    dead = true
    if is_big:
        GameManager.camera_shake_oneshot()
    else:
        GameManager.camera_shake_lite_oneshot()
    SoundEffects.play_ball_burst()
    $Particles.emitting = true
    SoundEffects.play_ball_burst()
    set_collision_layer_value(1, false)

    await get_tree().create_timer(1.0).timeout
    queue_free()
