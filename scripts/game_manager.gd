extends Node

@export var in_round = true
var gems: float = 0.0
var trove_level: int = 2

@onready var upgrade_ui = $"/root/Node2D/UpgradeUI"
@onready var all_troves = $"/root/Node2D/AllTroves"
@onready var enemy_spawner = $"/root/Node2D/EnemySpawner"

func _ready() -> void:
    if in_round:
        _start_round()
    else:
        _end_round()

func _process(_delta: float) -> void:
    if in_round and all_troves.get_child(0).get_child_count() == 0:
        _end_round()

func _start_round() -> void:
    upgrade_ui.global_position.y = 756.0
    var troves = load("res://scenes/trove_layout_%d.tscn" % trove_level).instantiate()
    all_troves.add_child.call_deferred(troves)
    in_round = true

func _end_round() -> void:
    in_round = false
    for trove_layout in all_troves.get_children():
        trove_layout.queue_free()
    enemy_spawner.kill_all_enemies()
    upgrade_ui.global_position.y = -108.0
