extends KinematicBody2D

onready var enemy1 = get_node("enemy1")
onready var gallop_sound = get_node("gallop")
onready var sample_timer = get_node("sample_timer")
onready var gallop_spread = get_node("gallop_spread")

var pos = Vector2()
var speed
var rot = 0
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)
var AVOID_RADIUS = 150
var DETECT_RADIUS = 1200
var FRICTION = -500
var empty_selector
var target = Vector2()
var target_dist
var touching = false
var player_touching
var col_body = null




func init(spawnpos):
	pos = spawnpos

func _ready():
	randomize()
	speed = global.mob_speeds[randi()%6]
	empty_selector = randi()%5
	#set_fixed_process(true)
	global_position = pos#set_pos(pos)
	gallop_spread.set_wait_time(randf())
	
	
	
func _fixed_process(delta):
	if gallop_spread.get_time_left() == 0:
		play_gallop()
	target = global.playerhorse_pos
	target_dist = target - pos
	avoid_horses()
	if touching == false:
		if pos.x < target.x:
			target_dist -= Vector2(50, -10)
			acc += target_dist.normalized()
		elif pos.x > target.x:
			target_dist += Vector2(50, -10)
			acc += target_dist.normalized()
		rot = target_dist.angle_to(Vector2(1, 0))
		acc = Vector2(1, 0).rotated(-rot)
		if acc != Vector2(0,0):
			if target_dist.length() > 200:
				acc *= rand_range(250, 300)
			elif target_dist.length() <= 200:
				acc *= speed
		acc += vel * -1
		vel += acc * delta
		pos += vel * delta + 0.5 * acc * delta*delta
		"""
		update above, and not just here but on all horse scenes, to move_and_slide or collide
		"""
		global_position = pos
		#set_pos(pos)
		
	elif touching == true:
		if col_body != null:
			if pos.x > col_body.pos.x:
				vel += Vector2(5, 0)
			elif pos.x < col_body.pos.x:
				vel -= Vector2(5, 0)
			pos += vel * delta
			global_position = pos
			
	
	if enemy1.health <= 0:
		vel = global.emptyhorse_vels[empty_selector]
		if pos.x > 1300 or pos.x < -100 or pos.y > 800 or pos.y < -100:
			remove_from_group("horses")
			enemy1.queue_free()
			queue_free()
	

func play_gallop():
	if sample_timer.get_time_left() == 0:
		sample_timer.start()
		gallop_sound.play("horse_gallop_final")


func avoid_horses():
	for horse in get_tree().get_nodes_in_group("horses"):
		if horse != self:  
			var avoid_dist = pos - horse.pos
			if avoid_dist.length() < 50:
				if abs(avoid_dist.x) < 35:
					if pos.x > horse.pos.x:
						vel = Vector2(50, 0)
					if pos.x < horse.pos.x:
						vel = Vector2(-50, 0)
#	if touching == true:
#		if col_body != null:
#			if not col_body.get_groups().has("player_horses"):
#				if col_body.get_groups().has("horses"):
#				
#					if player_touching == false:
#						if col_body.get_groups().has("horses"):
#							if pos.x > col_body.pos.x:
#								if col_body.vel.x > 0:
#									vel.x = col_body.vel.x + 40
#								if col_body.vel.x == 0:
#									vel.x = 0
#							if pos.x < col_body.pos.x:
#								if col_body.vel.x < 0:
#									vel.x = col_body.vel.x - 40
#								if col_body.vel.x == 0:
#									vel.x = 0
#							if pos.y > col_body.pos.y:
#								if col_body.vel.y > 0:
#									vel.y = col_body.vel.y + 40
#								if col_body.vel.y == 0:
#									vel.y = 0
#							if pos.y < col_body.pos.y:
#								if col_body.vel.y < 0:
#									vel.y = col_body.vel.y - 40
#								if col_body.vel.y == 0:
#									vel.y = 0
#				elif col_body.get_groups().has("player_horses"):
#					if pos.x > col_body.pos.x:
#						if col_body.vel.x > 0:
#							vel.x = col_body.vel.x + 40
#						if col_body.vel.x == 0:
#							vel.x = 0
#					if pos.x < col_body.pos.x:
#						if col_body.vel.x < 0:
#							vel.x = col_body.vel.x - 40
#						if col_body.vel.x == 0:
#							vel.x = 0
#					if pos.y > col_body.pos.y:
#						if col_body.vel.y > 0:
#							vel.y = col_body.vel.y + 40
#						if col_body.vel.y == 0:
#							vel.y = 0
#					if pos.y < col_body.pos.y:
#						if col_body.vel.y < 0:
#							vel.y = col_body.vel.y - 40
#						if col_body.vel.y == 0:
#							vel.y = 0
#				

func _on_collision_body_enter( body ):
	
	if body != self:
		#if not body.get_groups().has("player_horses"):
		if body.get_groups().has("horses"):
			col_body = body
			touching = true
			vel = Vector2(0, 0)
#			if pos.x > body.pos.x:
#				if body.vel.x > 0:
#					vel.x = body.vel.x + 40
#				if body.vel.x == 0:
#					vel.x = 0
#			if pos.x < body.pos.x:
#				if body.vel.x < 0:
#					vel.x = body.vel.x - 40
#				if body.vel.x == 0:
#					vel.x = 0
#			if pos.y > body.pos.y:
#				vel += Vector2(0, 50)
#			if pos.y < body.pos.y:
#				vel -= Vector2(0, 50)
	if body.get_groups().has("player_horses"):
		player_touching = true
		if enemy1.health <= 0:
			vel = body.vel
#		if pos.x > body.pos.x:
#			if body.vel.x > 0:
#				vel.x = body.vel.x + 40
#			if body.vel.x == 0:
#				vel.x = 0
#		if pos.x < body.pos.x:
#			if body.vel.x < 0:
#				vel.x = body.vel.x - 40
#			if body.vel.x == 0:
#				vel.x = 0
#		if pos.y > body.pos.y:
#			vel += Vector2(0, 50)
#		if pos.y < body.pos.y:
#				vel -= Vector2(0, 50)
#		
#			
#			


func _on_collision_body_exit( body ):
	touching = false
	if body.get_groups().has("player_horses"):
		player_touching = false
