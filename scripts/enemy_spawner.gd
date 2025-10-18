extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

func _ready() -> void:
    _spawn_async()

func _spawn_async() -> void:
    while true:
        await get_tree().create_timer(1.0).timeout
        var enemy: Node2D = enemy_scene.instantiate()
        var r: Rect2 = get_viewport().get_canvas_transform().inverse() * get_viewport_rect()
        get_tree().current_scene.add_child(enemy)
        enemy.global_position = _choose_boundary_point(r)
        print("creating enemy")

func _choose_boundary_point(r: Rect2) -> Vector2:
    var p = lerp(r.position, r.end, randf())
    var rand = randf()
    if rand < 0.25:
        p.x = r.position.x
        print("created on left side")
    elif rand < 0.5:
        p.x = r.end.x
        print("created on right side")
    elif rand < 0.75:
        p.y = r.position.y
        print("created on top side")
    else:
        p.y = r.end.y
        print("created on bottom side")
    return p