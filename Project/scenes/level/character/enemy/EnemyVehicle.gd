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
export var separation_force: = 0.025
export(float) var view_distance: = 50.0
export(float) var avoid_distance: = 20.0

const AVOID_RADIUS = 150
const DETECT_RADIUS = 1200
const FRICTION = -500

var target = Vector2()
var target_dist

var driver
var passenger

var in_shoot_range = false

var Enemy = preload("res://scenes/level/character/enemy/Enemy.tscn")

var MetalImpact = preload("res://scenes/level/character/MetalImpact.tscn")

onready var front_tire = $SpriteRear/SpriteFront/SpriteTire
onready var seat1 = $SpriteRear/Seat1
onready var seat2 = $SpriteRear/Seat2

func _ready():
	randomize()
	$BoidArea2D.get_node("CollisionShape2D").shape.radius = view_distance
	
func init(spawnpos, type):
	global_position = spawnpos
	if type == "MotorcycleSolo":
		pass
		
	var e1 = Enemy.instance()
	seat1.add_child(e1)
	e1.init(seat1.global_position, "Driver")
	driver = e1
		
		#$Seat1.add_child()
	if type == "MotorcycleDuo":
		var e2 = Enemy.instance()
		seat2.add_child(e2)
		e2.init(seat2.global_position, "Passenger")
		passenger = e2
		
		
func _hit_metal(hit_pos):
	var m = MetalImpact.instance()
	add_child(m)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	m.global_rotation = rng.randi_range(-180, 180)
	m.global_position = hit_pos
	m.play('default')
	
func _hit_tire(hit_pos):
	front_tire.play("flat")
	
	#reusing MetalImpact for this
	var t = MetalImpact.instance()
	add_child(t)
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	t.global_rotation = rng.randi_range(-180, 180)
	t.tire = true
	#t.speed_scale = 2
	t.scale = Vector2(2, 2)
	t.global_position = hit_pos
	t.modulate = Color.black
	t.play("default")
		
func _physics_process(delta):
	emit_signal("skid", global_position + Vector2(0, 10), "tire")
	
	if global_position.x >= global.player.global_position.x:
		target = global.player.chase_pos_right.global_position
	else:
		target = global.player.chase_pos_left.global_position
	$Icon.global_position = target

	
	var acceleration = Vector2.ZERO
	var vectors = get_flock_status()
	
	# steer towards vectors
	var cohesion_vector = vectors[0] * cohesion_force
	var align_vector = vectors[1] * algin_force
	var separation_vector = vectors[2] * separation_force
	var target_vector = (target - global_position).normalized() * speed * 0.05

	acceleration = cohesion_vector + align_vector + separation_vector + target_vector
	
	vel = (vel + acceleration).clamped(speed)
	var turn_dir
	if vel.x > 70:
		turn_dir = "TurnLeft"
		$AnimationPlayer.play("MotorcycleTurnLeft")
	elif vel.x < -70:
		turn_dir = "TurnRight"
		$AnimationPlayer.play("MotorcycleTurnRight")
	else:
		turn_dir = "Straight"
		$AnimationPlayer.play("Motorcycle"+turn_dir)
	driver.set_anim("MotorcycleDriver"+turn_dir)
	if passenger && in_shoot_range:
		passenger.shoot()

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
	if self != body:# && body.is_in_group("enemy"):
		_flock.append(body)


func _on_BoidArea2D_body_exited(body):
	if self != body && _flock.has(body):
		_flock.remove(_flock.find(body))


func _on_ShootRange_body_entered(body):
	if body.is_in_group("Player"):
		in_shoot_range = true


func _on_ShootRange_body_exited(body):
	if body.is_in_group("Player"):
		in_shoot_range = false
