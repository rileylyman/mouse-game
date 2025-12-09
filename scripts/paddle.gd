class_name Paddle extends Node2D

@onready var heart: Node2D = %Heart
@onready var paddle1: Node2D = $Sprite2D
@onready var paddle2: Node2D = $Sprite2D2
@onready var paddle3: Node2D = $Sprite2D3

var angle: float = 0.0
var radius: float = 300.0
var arc_deg: float = deg_to_rad(60.0)
var triple = false

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
    paddle1.global_position = heart.global_position + Vector2.RIGHT.rotated(angle) * radius
    paddle1.rotation = angle + PI / 2

    if triple:
        paddle2.global_position = heart.global_position + Vector2.RIGHT.rotated(angle + TAU / 3) * radius
        paddle2.rotation = (angle + TAU / 3) + PI / 2
        paddle3.global_position = heart.global_position + Vector2.RIGHT.rotated(angle + 2 * TAU / 3) * radius
        paddle3.rotation = (angle + 2 * TAU / 3) + PI / 2
    else:
        paddle2.global_position = Vector2(10000, 10000)
        paddle3.global_position = Vector2(10000, 10000)
    queue_redraw()

func _draw() -> void:
    draw_arc(Vector2.ZERO, radius, angle - arc_deg / 2, angle + arc_deg / 2, 32, Color.WHITE, 16, false)
    if triple:
        draw_arc(Vector2.ZERO, radius, angle + TAU / 3 - arc_deg / 2, angle + TAU / 3 + arc_deg / 2, 32, Color.WHITE, 16, false)
        draw_arc(Vector2.ZERO, radius, angle + 2 * TAU / 3 - arc_deg / 2, angle + 2 * TAU / 3 + arc_deg / 2, 32, Color.WHITE, 16, false)
