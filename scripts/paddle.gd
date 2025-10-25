extends Node2D

@onready var heart: Node2D = %Heart

var angle: float = 0
var radius: float = 1
var radius_max: float = 400

func _process(_delta: float) -> void:
    global_position = heart.global_position
    var dir = get_global_mouse_position() - global_position
    angle = Vector2.RIGHT.angle_to(dir.normalized())
    radius = dir.length()
    if radius != radius_max:
        radius = radius_max
        Input.warp_mouse(get_viewport().get_camera_2d().get_canvas_transform() * (global_position + dir.normalized() * radius))
    queue_redraw()

func _draw() -> void:
    var arc_len = 200
    var angle_len = min(arc_len / radius, PI / 4)
    draw_arc(Vector2.ZERO, radius, angle - angle_len / 2, angle + angle_len / 2, 32, Color.WHITE, 16, false)
