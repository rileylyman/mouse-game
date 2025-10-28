extends Node

@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var heart_proj_cont: Node2D = $"/root/Node2D/HeartProjectileContainer"
@onready var paddle: Paddle = $"/root/Node2D/Paddle"
@onready var enemy_spawner: EnemySpawner = $"/root/Node2D/EnemySpawner"
var final_particles: PackedScene = preload("res://scenes/final_particles.tscn")

var time_s: float = 0
var desired_time_scale: float = 1.0
var ended: bool = false 

func _process(_delta: float) -> void:
    if not ended and heart.is_dead():
        ended = true
        _end()
    time_s += _delta

    if Input.is_physical_key_pressed(KEY_ALT):
        if Input.is_physical_key_pressed(KEY_1):
            desired_time_scale = 1.0
        elif Input.is_physical_key_pressed(KEY_2):
            desired_time_scale = 0.25
        elif Input.is_physical_key_pressed(KEY_3):
            desired_time_scale = 0.5
        elif Input.is_physical_key_pressed(KEY_4):
            desired_time_scale = 2.0
        elif Input.is_physical_key_pressed(KEY_5):
            desired_time_scale = 4.0
        elif Input.is_physical_key_pressed(KEY_6):
            desired_time_scale = 8.0

    if BeatManager.fast_forward:
        Engine.time_scale = 10.0
        AudioServer.playback_speed_scale = 10.0
    else:
        Engine.time_scale = desired_time_scale
        AudioServer.playback_speed_scale = desired_time_scale


func _end():
    await get_tree().create_timer(2.0).timeout
    var children = heart_proj_cont.get_children() + enemy_spawner.get_children()
    for c in children + [heart.find_child("HeartOut"), heart.find_child("HeartOutBeat")]:
        SoundEffects.play_ball_burst()
        var p: CPUParticles2D = final_particles.instantiate()
        p.global_position = c.global_position
        p.emitting = true
        get_tree().current_scene.add_child.call_deferred(p)
        c.queue_free()
    await get_tree().create_timer(3.0).timeout
    get_tree().quit()
