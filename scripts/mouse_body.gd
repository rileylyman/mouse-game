class_name MouseBody extends RigidBody2D


@onready var wball_body: RigidBody2D = get_node("../WreckingBallBody")

func _ready() -> void:
    pass


func _process(_delta: float) -> void:
    position = get_global_mouse_position()
