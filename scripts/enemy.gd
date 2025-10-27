extends Area2D

var health: float = 10
var in_laser = false
var dtps = 100.0
var speed = 150.0
var dir = Vector2.RIGHT
var distance = 4000.0
var dead = false

@onready var start = global_position
@onready var heart: Heart = $"/root/Node2D/Heart"

func _ready() -> void:
    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
    if heart.is_dead():
        return
    if in_laser:
        health -= dtps * _delta
    if health <= 0:
        die()

    global_position += dir * speed * _delta
    if global_position.distance_to(start) > distance:
        queue_free()

func die():
    if dead:
        return
    dead = true
    $"/root/Node2D/Heart".take_damage()
    $Sprite2D.queue_free()
    $Particles.emitting = true
    await get_tree().create_timer(1.5).timeout
    queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area is HeartBall:
        health -= 10
        area.die()
    elif area is Laser:
        in_laser = true

func _on_area_exited(area: Area2D) -> void:
    if area is Laser:
        in_laser = false
