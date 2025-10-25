class_name Paddle extends Node2D

@onready var heart: Node2D = %Heart
@onready var paddle: Node2D = $Sprite2D

var angle: float = 0.0
var radius: float = 1.0
var radius_max: float = 300.0
var arc_len: float = 200.0
var angle_len: float = 0.0

func _process(_delta: float) -> void:
    global_position = heart.global_position
    var dir = get_global_mouse_position() - global_position
    angle = Vector2.RIGHT.angle_to(dir.normalized())
    radius = dir.length()
    if radius != radius_max:
        radius = radius_max
        Input.warp_mouse(get_viewport().get_camera_2d().get_canvas_transform() * (global_position + dir.normalized() * radius))
    queue_redraw()

    paddle.global_position = heart.global_position + Vector2.RIGHT.rotated(angle) * radius
    paddle.rotation = angle + PI / 2

func _draw() -> void:
    angle_len = min(arc_len / radius, PI / 4)
    draw_arc(Vector2.ZERO, radius, angle - angle_len / 2, angle + angle_len / 2, 32, Color.WHITE, 16, false)
