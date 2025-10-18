extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

func _ready() -> void:
    _spawn_async()

func _spawn_async() -> void:
    while true:
        await get_tree().create_timer(1.0).timeout
        var enemy: Node2D = enemy_scene.instantiate()
        var r: Rect2 = get_viewport().get_canvas_transform().inverse() * get_viewport_rect()
        enemy.position = _choose_boundary_point(r)
        add_child(enemy)

func _choose_boundary_point(r: Rect2) -> Vector2:
    var p = lerp(r.position, r.end, randf())
    var rand = randf()
    if rand < 0.25:
        p.x = r.position.x
    elif rand < 0.5:
        p.x = r.end.x
    elif rand < 0.75:
        p.y = r.position.y
    else:
        p.y = r.end.y
    return p