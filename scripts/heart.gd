extends Node2D


@onready var beat: Node2D = $HeartOutBeat
@onready var original_scale: Vector2 = scale

var second_per_beat: float = 0.375

func _ready() -> void:
    _beat_async()


func _beat_async() -> void:
    beat.visible = false
    while true:
        await get_tree().create_timer(second_per_beat * 1.5).timeout
        beat.visible = true
        scale = original_scale * 1.25
        await get_tree().create_timer(second_per_beat * 0.5).timeout
        beat.visible = false
        scale = original_scale