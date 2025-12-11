class_name HeartProjCont extends Node2D

@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var paddle: Paddle = $"/root/Node2D/Paddle"

func get_laser_dir() -> Vector2:
    var laser: Laser = null
    for c in get_children():
        if c is Laser:
            laser = c
            break
    if not laser:
        return Vector2.ZERO
    return Vector2.RIGHT.rotated(laser.rotation)

func get_closest_ball_to_paddle() -> HeartBall:
    var balls: Array[HeartBall] = []
    for c in get_children():
        if c is HeartBall:
            balls.append(c)
    var closest: HeartBall = null
    var closest_dist: float = INF
    for c in get_children():
        if c is not HeartBall or c.dead:
            continue
        var dist = paddle.radius - c.global_position.distance_to(heart.global_position)
        if dist < 0:
            continue
        if dist < closest_dist:
            closest = c
            closest_dist = dist
        
    return closest
