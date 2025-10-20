extends Area2D

var max_health: int = 5
@onready var health_bar: HealthBar = $HealthBar
@onready var health: int = max_health

func _ready() -> void:
    body_entered.connect(func(_body: RigidBody2D):
        health = max(0, health - 1)
        health_bar.health_t = float(health) / max_health
        if health <= 0:
            queue_free()
            GameManager._start_round()
    )
