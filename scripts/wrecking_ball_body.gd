class_name WreckingBallBody extends RigidBody2D

@export var damage: float = 2.5

func _ready() -> void:
    $DampedSpringJoint2D.stiffness = 256