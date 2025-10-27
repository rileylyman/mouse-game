class_name HeartBall extends Area2D

var dir: Vector2
var speed: float = 100.0
var dead = false

static var take_sixteenths: int = 8 
var check_on_sixteenth: int = 0

@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var paddle: Paddle = $"/root/Node2D/Paddle"
@onready var paddle_area1: Area2D = $"/root/Node2D/Paddle/Sprite2D/PaddleArea"
@onready var paddle_area2: Area2D = $"/root/Node2D/Paddle/Sprite2D2/PaddleArea"
@onready var paddle_area3: Area2D = $"/root/Node2D/Paddle/Sprite2D3/PaddleArea"

func _ready() -> void:
    dir = dir.normalized()
    speed = paddle.radius / ((check_on_sixteenth - BeatManager.curr_sixteenth) * BeatManager.secs_per_beat / 4)

    _check_async()

func _check_async() -> void:
    await BeatManager.wait_for_sixteenth(check_on_sixteenth - 1)
    _check_paddle(paddle_area1)
    if heart.triple:
        _check_paddle(paddle_area2)
        _check_paddle(paddle_area3)

func _check_paddle(paddle_area: Area2D) -> void:
    var bv = global_position - heart.global_position
    var pv = paddle_area.global_position - heart.global_position
    if abs(bv.normalized().angle_to(pv.normalized())) < paddle.arc_deg / 2 + deg_to_rad(5.0):
        die()

func _process(delta: float) -> void:
    global_position += dir * speed * delta

    var r = global_position.distance_to(heart.global_position)
    if r > 4000.0:
        queue_free()

func _on_area_enter(area: Area2D) -> void:
    if area.name == "PaddleArea":
        die()

func die() -> void:
    if dead:
        return
    dead = true
    SoundEffects.play_ball_burst()
    $Sprite2D.queue_free()
    set_collision_layer_value(1, false)
    $Particles.emitting = true
    SoundEffects.play_ball_burst()
    await get_tree().create_timer(1.0).timeout
    queue_free()
