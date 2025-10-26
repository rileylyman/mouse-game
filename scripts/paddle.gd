class_name Paddle extends Node2D

@onready var heart: Node2D = %Heart
@onready var paddle: Node2D = $Sprite2D

var angle: float = 0.0
var radius: float = 200.0
var arc_len: float = 200.0

func _ready() -> void:
    global_position = heart.global_position
    # Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _old_input(event: InputEvent) -> void:
    if event is not InputEventMouseMotion:
        return
    var delta: Vector2 = event.relative
    var circle_pos = heart.global_position + radius * Vector2.RIGHT.rotated(angle)
    var to_center = (circle_pos - heart.global_position).normalized()

    var tangent = to_center.rotated(PI / 2)

    var angle_delta = deg_to_rad(delta.length()) * 0.5
    if abs(delta.angle_to(tangent)) > PI / 2:
        angle_delta *= -1

    angle += angle_delta
    queue_redraw()


func _process(_delta: float) -> void:
    var dir = (get_global_mouse_position() - heart.global_position).normalized()
    angle = Vector2.RIGHT.angle_to(dir)
    paddle.global_position = heart.global_position + Vector2.RIGHT.rotated(angle) * radius
    paddle.rotation = angle + PI / 2
    queue_redraw()

func _draw() -> void:
    var angle_len = min(arc_len / radius, PI / 4)
    draw_arc(Vector2.ZERO, radius, angle - angle_len / 2, angle + angle_len / 2, 32, Color.WHITE, 16, false)
