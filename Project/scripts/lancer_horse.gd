extends KinematicBody2D


#signal dead_archer


var pos = Vector2()

var speed = rand_range(900, 1450)
onready var lancer = get_node("lancer")
onready var gallop_sound = get_node("gallop")
onready var sample_timer = get_node("sample_timer")
onready var gallop_spread = get_node("gallop_spread")
onready var active = null
onready var target_selector = null
onready var target_ind = null
onready var empty_selector



var rot = 0
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)
var AVOID_RADIUS = 150
var DETECT_RADIUS = 1200
var FRICTION = -500
#var target2 = Vector2()
#var target_dist2
var touching
var player_touching
var col_body = null

var player_location = Vector2()
var target = Vector2()
var target_dist = Vector2()

var path_slope = Vector2()
var starting_pos = Vector2()


func init(spawnpos):
	randomize()
	pos = spawnpos
	starting_pos = pos

func _ready():
	randomize() 
	empty_selector = randi()%5     
	target_selector = randi()%11
	set_fixed_process(true)
	set_pos(pos)
	gallop_spread.set_wait_time(randf())
	
	path_slope = (global.playerhorse_pos.y - pos.y) / (global.playerhorse_pos.x - pos.x)
	
	
		
	

func _fixed_process(delta):	
	if gallop_spread.get_time_left() == 0:
		play_gallop()
#	target2 = global.playerhorse_pos
#	target_dist2 = target2 - pos
	avoid_horses()
	

#	if target_dist2.length() < 50:
#		if pos.x < target2.x:
#			vel -= Vector2(50, 0)
#		elif pos.x > target2.x:
#			vel += Vector2(50, 0)
#		acc += vel * -1
#		vel += acc * delta
#		pos += vel * delta + 0.5 * acc * delta*delta
	if global.playerhorse_pos.y  + 100 < pos.y:
		player_location = global.playerhorse_pos
	
#		target = global.playerhorse_pos #+ Vector2(100, 100)
		if player_location.x > pos.x:
			target = player_location + Vector2(150, 0)

		elif player_location.x <= pos.x:
			target = player_location + Vector2(-150, -300)
		target_dist = target - pos
		rot = target_dist.angle_to(Vector2(1, 0))
		acc = Vector2(1, 0).rotated(-rot)
		if acc != Vector2(0,0):
			acc *= speed
		acc += vel * -1
		vel += acc * delta
		pos += vel * delta + 0.5 * acc * delta*delta
	elif global.player_pos.y + 100 >= pos.y:
		target = Vector2(rand_range(0,1000), -300)
		target_dist = target - pos
		rot = target_dist.angle_to(Vector2(1, 0))
		acc = Vector2(1, 0).rotated(-rot)
		if acc != Vector2(0,0):
			acc *= speed
		acc += vel * -1
		vel += acc * delta
		pos += vel * delta + 0.5 * acc * delta*delta
		if pos.y <= -280:
			randomize()
			pos = Vector2(rand_range(0, 1000), 900)
			vel = Vector2(0, 0)
	set_pos(pos)
	
	if lancer.health <= 0:
		#emit_signal("dead_archer", get_pos())
		vel = global.deadlancer_vels[empty_selector]
		if pos.x > 1300 or pos.x < -100 or pos.y > 800 or pos.y < -100:
			lancer.queue_free()
			remove_from_group("horses")
			queue_free()
		
func play_gallop():
	if sample_timer.get_time_left() == 0:
		sample_timer.start()
		gallop_sound.play("horse_gallop_final")		
		
		
func avoid_horses():
	if touching == true:
		if col_body != null:
			if not col_body.get_groups().has("player_horses"):
				if col_body.get_groups().has("horses"):
				
					if player_touching == false:
						if col_body.get_groups().has("horses"):
							if pos.x > col_body.pos.x:
								if col_body.vel.x > 0:
									vel.x = col_body.vel.x + 40
								if col_body.vel.x == 0:
									vel.x = 0
							if pos.x < col_body.pos.x:
								if col_body.vel.x < 0:
									vel.x = col_body.vel.x - 40
								if col_body.vel.x == 0:
									vel.x = 0
							if pos.y > col_body.pos.y:
								if col_body.vel.y > 0:
									vel.y = col_body.vel.y + 40
								if col_body.vel.y == 0:
									vel.y = 0
							if pos.y < col_body.pos.y:
								if col_body.vel.y < 0:
									vel.y = col_body.vel.y - 40
								if col_body.vel.y == 0:
									vel.y = 0
				elif col_body.get_groups().has("player_horses"):
					if pos.x > col_body.pos.x:
						if col_body.vel.x > 0:
							vel.x = col_body.vel.x + 40
						if col_body.vel.x == 0:
							vel.x = 0
					if pos.x < col_body.pos.x:
						if col_body.vel.x < 0:
							vel.x = col_body.vel.x - 40
						if col_body.vel.x == 0:
							vel.x = 0
					if pos.y > col_body.pos.y:
						if col_body.vel.y > 0:
							vel.y = col_body.vel.y + 40
						if col_body.vel.y == 0:
							vel.y = 0
					if pos.y < col_body.pos.y:
						if col_body.vel.y < 0:
							vel.y = col_body.vel.y - 40
						if col_body.vel.y == 0:
							vel.y = 0
#				
#				

func _on_collision_body_enter( body ):
		
	if body != self:
		#if not body.get_groups().has("player_horses"):
		if body.get_groups().has("horses"):
			col_body = body
			touching = true
			if pos.x > body.pos.x:
				if body.vel.x > 0:
					vel.x = body.vel.x + 40
				if body.vel.x == 0:
					vel.x = 0
			if pos.x < body.pos.x:
				if body.vel.x < 0:
					vel.x = body.vel.x - 40
				if body.vel.x == 0:
					vel.x = 0
			if pos.y > body.pos.y:
				vel += Vector2(0, 50)
			if pos.y < body.pos.y:
				vel -= Vector2(0, 50)
	if body.get_groups().has("player_horses"):
		player_touching = true
		if pos.x > body.pos.x:
			if body.vel.x > 0:
				vel.x = body.vel.x + 40
			if body.vel.x == 0:
				vel.x = 0
		if pos.x < body.pos.x:
			if body.vel.x < 0:
				vel.x = body.vel.x - 40
			if body.vel.x == 0:
				vel.x = 0
		if pos.y > body.pos.y:
			vel += Vector2(0, 50)
		if pos.y < body.pos.y:
				vel -= Vector2(0, 50)
				
					


func _on_collision_body_exit( body ):
	touching = false
	if body.get_groups().has("player_horses"):
		player_touching = false
