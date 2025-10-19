extends RigidBody2D

@export var health: float = 10.0
@export var dps: float = 2.5
@export var attack_freq: float = 1.0
@export var speed: float = 100.0

@onready var all_troves: Node2D = $"/root/Node2D/AllTroves"
var target: Trove = null
var _last_hit: float = 0
var _hit_timeout: float = 0.5

func _ready() -> void:
    $Area2D.body_entered.connect(_on_wball_entered)

    _find_target()
    _dps_loop_async()

func _find_target() -> void:
    if target:
        return
    if all_troves.get_child_count() == 0:
        return
    var trove_children = all_troves.get_child(0).get_children()
    if trove_children.size() > 0:
        target = trove_children.pick_random()


func _dps_loop_async() -> void:
    var period = 1.0 / attack_freq
    while true:
        await get_tree().create_timer(period).timeout
        if target and target.overlaps_area($Area2D):
            target.take_damage(dps * period)

func _process(_delta: float) -> void:
    _find_target()
    if target == null:
        return
    if target.overlaps_area($Area2D):
        return

    var dir = (target.global_position - global_position).normalized()
    if (linear_velocity.project(dir * speed).length() < speed):
        apply_force((target.global_position - global_position).normalized() * speed * 10)

func _on_wball_entered(body: RigidBody2D) -> void:
    if body is not WreckingBallBody:
        return
    health -= body.damage
    if health <= 0:
        queue_free()
    if _last_hit + _hit_timeout < Time.get_ticks_msec() / 1000.0:
        apply_impulse(body.linear_velocity)
        body.linear_velocity *= 0.5
        # body.apply_impulse(-body.linear_velocity * 0.5)
