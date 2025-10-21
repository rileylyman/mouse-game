extends MarginContainer

@onready var panel = $Panel
@onready var label = $PanelContainer/Label

func _process(_delta: float) -> void:
    panel.custom_minimum_size.x = float(GameManager.wball_durability_curr) / GameManager.wball_durability_max * size.x
    label.text = "Durability: %d/%d" % [GameManager.wball_durability_curr, GameManager.wball_durability_max]