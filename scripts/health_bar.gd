class_name HealthBar extends Node2D

var health_t: float = 1.0

@onready var green_line: Line2D = $GreenLine
@onready var left = green_line.points[0].x
@onready var right = green_line.points[1].x

func _process(_delta: float) -> void:
    green_line.points[1].x = lerp(left, right, health_t)
