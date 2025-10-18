class_name Trove extends Area2D

@export var health: float = 10.0

func take_damage(damage: float) -> bool:
    health -= damage
    if health <= 0:
        queue_free()
        return true
    else:
        return false
