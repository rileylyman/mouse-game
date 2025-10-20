class_name UpgradeOption extends MarginContainer

var mouse_over = false

var gems_spent: float = 0.0
var fill_time: float = 3
@export var gems_required: float = 10.0
@export var func_to_call: String = ""
var complete = false

@onready var panel = $Panel
@onready var label = $PanelContainer/Label
@onready var original_text = label.text

var dot_ui = preload("res://scenes/dot_ui.tscn")
@onready var gems_to_spawn = 100
@onready var _spawn_gems_every = gems_required / gems_to_spawn
var _spent_gems_for_spawn = 0

func _ready() -> void:
    if !has_method(func_to_call):
        push_error("'%s' has no function '%s'" % [name, func_to_call])
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
    mouse_over = true

func _on_mouse_exited() -> void:
    mouse_over = false

func _process(delta: float) -> void:
    if mouse_over and gems_spent < gems_required:
        var to_spend = min(gems_required / fill_time * delta, gems_required - gems_spent, GameManager.gems)
        gems_spent += to_spend
        _spent_gems_for_spawn += to_spend
        GameManager.gems -= to_spend

        if _spent_gems_for_spawn >= _spawn_gems_every:
            _spent_gems_for_spawn -= _spawn_gems_every
            var dot = dot_ui.instantiate()
            dot.global_position = global_position + (2 * Vector2(randf(), randf()) - Vector2.ONE) * 600.0
            dot.target = global_position + size / 2
            get_tree().current_scene.add_child.call_deferred(dot)

        if not complete and gems_spent >= gems_required:
            complete = true
            _end_async()

    panel.custom_minimum_size.x = gems_spent / gems_required * size.x
    if not complete:
        label.text = "%s (%d/%d gems)" % [original_text, gems_spent, gems_required]

func _end_async() -> void:
    label.text = "Upgrade Purchased!"
    call_deferred(func_to_call)
    await get_tree().create_timer(2.0).timeout
    queue_free()

func _upgrade_trove_level() -> void:
    GameManager.trove_level += 1

func _upgrade_wball_count() -> void:
    GameManager._spawn_new_wball()

func _upgrade_trove_gps() -> void:
    GameManager.trove_gps *= 2.0
