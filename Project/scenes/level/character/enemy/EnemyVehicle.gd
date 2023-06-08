extends KinematicBody2D

signal skid

var pos = Vector2()
var speed = 120
var rot = 0
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)
var _flock = []
export var cohesion_force: = 0.05
export var algin_force: = 0.05
export var separation_force: = 0.05
export(float) var view_distance: = 50.0
export(float) var avoid_distance: = 20.0
#var acc = Vector2(0, 0)
const AVOID_RADIUS = 150
const DETECT_RADIUS = 1200
const FRICTION = -500
var empty_selector
var target = Vector2()
var target_dist
#var touching = false
#var player_touching
#var col_body = null
var driver
var passenger

var Enemy = preload("res://scenes/level/character/enemy/Enemy.tscn")

onready var seat1 = $SpriteRear/Seat1
onready var seat2 = $SpriteRear/Seat2

func _ready():
	randomize()
	#speed = 150#global.mob_speeds[randi()%6]
	empty_selector = randi()%5
	#global_position = pos#set_pos(pos)
	#gallop_spread.set_wait_time(randf())
	
	$BoidArea2D.get_node("CollisionShape2D").shape.radius = view_distance
	
func init(spawnpos, type):
	global_position = spawnpos
	if type == "MotorcycleSolo":
		pass
		
	var e1 = Enemy.instance()
	seat1.add_child(e1)
	e1.init(seat1.global_position, "Driver")
	e1.anim_player.play("MotorcycleDriver")
	driver = e1
		
		#$Seat1.add_child()
	if type == "MotorcycleDuo":
		var e2 = Enemy.instance()
		seat2.add_child(e2)
		e2.init(seat2.global_position, "Passenger")
		#e2.anim_player.play("MotorcyclePassenger")
		passenger = e2
		
func _physics_process(delta):
	emit_signal("skid", global_position + Vector2(0, 10), "tire")
	
	if global_position.x >= global.player.global_position.x:
		target = global.player.chase_pos_right.global_position
	else:
		target = global.player.chase_pos_left.global_position
	#if global_position.distance_to(target) < 50:
	#	target = global_position
	$Icon.global_position = target
	#target = global.player.global_position
	#target_dist = target - pos
	#acc += target_dist.normalized()
	
	var acceleration = Vector2.ZERO

	var vectors = get_flock_status()
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force
	var align_vector = vectors[1] * algin_force
	var separation_vector = vectors[2] * separation_force
	var target_vector = (target - global_position).normalized() * speed * 0.05
#	if global_position.distance_to(global.player.global_position) < 50:
#		target_vector = Vector2.ZERO
	acceleration = cohesion_vector + align_vector + separation_vector + target_vector
	
	vel = (vel + acceleration).clamped(speed)
	if vel.x > 70:
		$AnimationPlayer.play("MotorcycleTurnLeft")
	elif vel.x < -70:
		$AnimationPlayer.play("MotorcycleTurnRight")
	else:
		$AnimationPlayer.play("MotorcycleStraight")
	#driver.set_anim($AnimationPlayer.current_animation)
	#if passenger:
	#	passenger.set_anim("MotorcyclePassenger")

	var collision = move_and_collide(vel * delta)
	if collision:
		pass

	

func get_flock_status():
	var center_vector: = Vector2()
	var flock_center: = Vector2()
	var align_vector: = Vector2()
	var avoid_vector: = Vector2()
	
	for f in _flock:
		var neighbor_pos: Vector2 = f.global_position

		align_vector += f.vel
		flock_center += neighbor_pos

		var d = global_position.distance_to(neighbor_pos)
		if d > 0 and d < avoid_distance:
			avoid_vector -= (neighbor_pos - global_position).normalized() * (avoid_distance / d * speed)
	
	var flock_size = _flock.size()
	if flock_size:
		align_vector /= flock_size
		flock_center /= flock_size

		var center_dir = global_position.direction_to(flock_center)
		var center_speed = speed * (global_position.distance_to(flock_center) / view_distance)
		center_vector = center_dir * center_speed

	return [center_vector, align_vector, avoid_vector]



func _on_BoidArea2D_body_entered(body):
	if self != body:
		_flock.append(body)


func _on_BoidArea2D_body_exited(body):
	if self != body:
		_flock.remove(_flock.find(body))
