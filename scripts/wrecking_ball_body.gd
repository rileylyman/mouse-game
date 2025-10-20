class_name WreckingBallBody extends RigidBody2D

@export var damage: float = 2.5
@export var length: float = 35.0

func _ready() -> void:
    var joint = $DampedSpringJoint2D
    joint.length = length
    joint.rest_length = length
    joint.stiffness = 256