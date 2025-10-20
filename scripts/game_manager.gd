extends Node

@export var in_round = false
var gems: float = 100.0
var trove_level: int = 1
var trove_gps: float = 2 
var trove_gem_value: float = 1.0

var wball_level: int = 1

var start_tub = preload("res://scenes/start_tub.tscn")
var wball_scene = preload("res://scenes/wrecking_ball_body.tscn")

@onready var upgrade_ui = $"/root/Node2D/UpgradeUI"
@onready var all_troves = $"/root/Node2D/AllTroves"
@onready var enemy_spawner = $"/root/Node2D/EnemySpawner"
@onready var camera = $"/root/Node2D/Camera2D"
@onready var camera_rect = Utils.ws_rect(camera)

func _ready() -> void:
    if in_round:
        _start_round()
    else:
        _end_round()

func _process(_delta: float) -> void:
    if in_round and all_troves.get_child(0).get_child_count() == 0:
        _end_round()

func _start_round() -> void:
    upgrade_ui.global_position = camera_rect.position + camera_rect.size / 2 + Vector2(0, 1000)
    var troves = load("res://scenes/trove_layout_%d.tscn" % trove_level).instantiate()
    all_troves.add_child.call_deferred(troves)
    in_round = true

func _end_round() -> void:
    in_round = false
    for trove_layout in all_troves.get_children():
        trove_layout.queue_free()
    enemy_spawner.kill_all_enemies()
    upgrade_ui.global_position = camera_rect.position + camera_rect.size / 2

    await get_tree().create_timer(3).timeout

    var tub = start_tub.instantiate()
    upgrade_ui.add_child.call_deferred(tub)

func _spawn_new_wball() -> void:
    wball_level += 1
    var wball = wball_scene.instantiate()
    wball.length = 40.0 * wball_level
    # wball.global_position = $"/root/Node2D/MouseBody".global_position
    wball.global_position = $"/root/Node2D".get_global_mouse_position()
    $"/root/Node2D".add_child.call_deferred(wball)
