class_name EnemySpawner extends Node2D

@onready var heart: Heart = %Heart
var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")
var enemy_scene2: PackedScene = preload("res://scenes/enemy2.tscn")

func _ready() -> void:
    _spawn_async()
    pass

func _spawn_async() -> void:
    await BeatManager.start_signal
    await _spawn_all_sides(2.0, 4 * 60.0)

func _spawn_all_sides(interval: float, duration: float) -> void:
    var camr = Utils.ws_rect($"/root/Node2D/Camera2D")
    var pad = camr.size * 0.1
    var start = GameManager.time_s
    var scene = enemy_scene
    while not heart.is_dead() and GameManager.time_s - start < duration:
        var i = 0
        for p in [
                [camr.position + Vector2(0, camr.size.y) + Vector2.RIGHT * pad.x, Vector2.UP],
                [camr.position + Vector2(camr.size.x, 0) + Vector2.LEFT * pad.x, Vector2.DOWN], 
                [camr.position + Vector2.DOWN * pad.y, Vector2.RIGHT], 
                [camr.end + Vector2.UP * pad.y, Vector2.LEFT],
                ]:
            var enemy: Node2D = scene.instantiate()
            enemy.global_position = p[0]
            enemy.dir = p[1]
            add_child(enemy)
            if i == 1 or i == 3:
                await get_tree().create_timer(interval / 2).timeout
            i += 1
        scene = enemy_scene2 if scene == enemy_scene else enemy_scene
        # await get_tree().create_timer(interval).timeout

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

func kill_all_enemies() -> void:
    for enemy in get_children():
        enemy.queue_free()
