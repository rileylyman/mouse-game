extends Node

@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var heart_proj_cont: Node2D = $"/root/Node2D/HeartProjectileContainer"
@onready var paddle: Paddle = $"/root/Node2D/Paddle"
@onready var enemy_spawner: EnemySpawner = $"/root/Node2D/EnemySpawner"
@onready var camera: Camera2D = $"/root/Node2D/Camera2D"
@onready var camera_ap: AnimationPlayer = $"/root/Node2D/Camera2D/AnimationPlayer"
@onready var stats_label: Label = $"/root/Node2D/Panel/StatsLabel"
var final_particles: PackedScene = preload("res://scenes/final_particles.tscn")

var time_s: float = 0
var desired_time_scale: float = 1.0
var ended: bool = false 

var balls_died: int = 0
var balls_caught: int = 0
var laser_time_s: float = 0
var laser_time_caught_s: float = 0

func _laser_to_balls(laser: float) -> int:
    return int(laser * 10)


func _process(_delta: float) -> void:
    var total_caught = balls_caught + _laser_to_balls(laser_time_caught_s)
    var total = balls_died + _laser_to_balls(laser_time_s)
    if total == 0:
        total_caught = 1
        total = 1
    # stats_label.text = "%.0f%%" % floor(float(total_caught) / total * 100)
    stats_label.text = "%.0f%%" % floor(float(heart.health) / heart.max_health * 100)
    if not ended and heart.is_dead():
        ended = true
        _end()
    time_s += _delta

    if Input.is_physical_key_pressed(KEY_ESCAPE):
        quit()

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

    #if BeatManager.fast_forward:
    #    Engine.time_scale = 10.0
    #    AudioServer.playback_speed_scale = 10.0
    #else:
    Engine.time_scale = desired_time_scale
    AudioServer.playback_speed_scale = desired_time_scale


func _end():
    for c in heart_proj_cont.get_children():
        c.queue_free()
    while not heart.end_sequence_played:
        await get_tree().create_timer(0.1).timeout
    var children = enemy_spawner.get_children()
    for c in children + [heart.find_child("VisualContainer")]:
        SoundEffects.play_ball_burst()
        var p: GPUParticles2D = final_particles.instantiate()
        p.global_position = c.global_position
        p.emitting = true
        get_tree().current_scene.add_child.call_deferred(p)
        c.queue_free()
    paddle.queue_free()
    await get_tree().create_timer(3.0).timeout
    quit()

func quit() -> void: 
    if BeatManager.on_web:
        JavaScriptBridge.eval("window.location.reload()")
    else:
        get_tree().quit()

var camera_shaking := false
func camera_shake(enable: bool) -> void:
    if not camera_shaking and enable:
        camera_shaking = true
        camera_ap.play("screen_shake")
    elif camera_shaking and not enable:
        camera_shaking = false
        await get_tree().create_timer(0.5).timeout
        if not camera_shaking:
            camera_ap.play("RESET")

func camera_shake_oneshot() -> void:
    if camera_shaking:
        return
    camera_ap.play("screen_shake")
    await camera_ap.shake_loop
    if not camera_shaking:
        camera_ap.play("RESET")

func camera_shake_lite_oneshot() -> void:
    if camera_shaking or camera_ap.current_animation != "":
        return
    camera_ap.play("screen_shake_lite")
    await camera_ap.shake_loop
    if not camera_shaking and camera_ap.current_animation == "screen_shake_lite":
        camera_ap.play("RESET")
    
