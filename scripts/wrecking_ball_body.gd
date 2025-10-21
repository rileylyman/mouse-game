class_name WreckingBallBody extends RigidBody2D

@export var length: float = 35.0

func _ready() -> void:
    var joint = $DampedSpringJoint2D
    joint.length = length
    joint.rest_length = length
    joint.stiffness = 256

func _process(_delta: float) -> void:
    visible = GameManager.wball_durability_curr > 0