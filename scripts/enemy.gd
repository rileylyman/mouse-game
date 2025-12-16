extends Area2D

var health: float = 10
var in_laser = false
var dtps = 100.0
var speed = 150.0
var dir = Vector2.RIGHT
var distance = 4000.0
var dead = false

@export var enemy_type: int = 0

@onready var start = global_position
@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var sprite: Node2D = $Sprite2D
@onready var sprite_orig_scale = sprite.scale

func _ready() -> void:
    area_entered.connect(_on_area_entered)
    area_exited.connect(_on_area_exited)
    _periodic_pulse()

func _periodic_pulse() -> void:
    await BeatManager.next_bar()
    while not dead:
        if BeatManager.is_fast_forwarding():
            await get_tree().create_timer(1.0).timeout
        await BeatManager.next_4()
        _pulse()
        await BeatManager.next_4()
        await BeatManager.next_4()
        _pulse()
        await BeatManager.next_bar()

func _pulse() -> void: 
    if not dead:
        var tween = create_tween()
        tween.tween_property(sprite, "scale", sprite_orig_scale * Vector2(1.2, 1.2), 0.1)
        tween.tween_property(sprite, "scale", sprite_orig_scale * Vector2(1, 1), 0.05)

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
    $Glow.queue_free()
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
