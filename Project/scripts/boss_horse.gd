extends KinematicBody2D





onready var boss = get_node("boss")
onready var gallop_sound = get_node("gallop")
onready var sample_timer = get_node("sample_timer")  

var speed = global.boss_speed
var pos = Vector2()
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)
var rot = 0
var AVOID_RADIUS = 150
var DETECT_RADIUS = 1200
var colliding = null
var collide_pos = null
var collide_vel = null
var no_collision = null
var target
var target_dist

func init(spawnpos):
	pos = spawnpos

func _ready():
	global_position = pos
#	set_fixed_process(true)
#	set_pos(pos)


func _physics_process(delta):
	play_gallop()
	avoid_horses()     
	if boss.dying == false:
		if pos.x > 1150:
			pos.x = 1150
		elif pos.x < 50:
			pos.x = 50
		if pos.y > 650:
			pos.y = 650
		
		if boss.charging == true:
			
		#if is_colliding():
		#	print("fffff")
		#	print(get_collider())
		
			target = global.playerhorse_pos + Vector2(130, 0)
			target_dist = target - pos
			if abs(target_dist.x) < 30:
				vel += Vector2(1, 0)
			if target_dist.length_squared() < DETECT_RADIUS*DETECT_RADIUS:             # do length_squared b/c taking square root can be slow
			
			                                                            #if random() < 0.002:
				rot = target_dist.angle_to(Vector2(1, 0))
	
				acc = Vector2(1, 0).rotated(-rot)
				if acc != Vector2(0,0):
					acc *= speed
			
				acc += vel * -1
				vel += acc * delta
				pos += vel * delta + 0.5 * acc * delta*delta
		elif boss.arching == true:
			target = global.player_pos + Vector2(600, 0)
			target_dist = target - pos
			if abs(target_dist.y) > 10:
				if pos.y > target.y:
					vel.y -= 5
				elif pos.y < target.y:
					vel.y += 5
			if target_dist.length_squared() < DETECT_RADIUS*DETECT_RADIUS:             # do length_squared b/c taking square root can be slow
			
			                                                            #if random() < 0.002:
				rot = target_dist.angle_to(Vector2(1, 0))
	
				acc = Vector2(1, 0).rotated(-rot)
				if acc != Vector2(0,0):
					acc *= speed
			
				acc += vel * -1
				vel += acc * delta
				pos += vel * delta + 0.5 * acc * delta*delta
				
		elif boss.pounding == true:
			target = global.player_pos + Vector2(-38, -20)
			
			target_dist = target - pos
			#if pos.x >= target.x:
			#	vel.x -= 5
			if target_dist.length_squared() < DETECT_RADIUS*DETECT_RADIUS: 
				rot = target_dist.angle_to(Vector2(1, 0))
				acc = Vector2(1, 0).rotated(-rot)
				if acc != Vector2(0,0):
					acc *= speed
				acc += vel * -1
				vel += acc * delta
				pos += vel * delta + 0.5 * acc * delta*delta
				
	
	else:
		vel = global.emptyhorse_vels[3]
		
	
	
	
	
	global_position = pos
	
	


func play_gallop():
	if sample_timer.get_time_left() == 0:
		sample_timer.start()
		gallop_sound.play("horse_gallop_final")



func avoid_horses():
	
	if colliding != null:
		#print(colliding.get_name())
		if colliding != self:
			if no_collision == false:
			
				if colliding.get_groups().has("horses"):
					var dist = collide_pos - pos
					#vel.x = -collide_vel.x
				
					if 0 < dist.length() < 50:
					#	acc += dist.normalized()
						if pos.x > collide_pos.x:
							vel += Vector2(20, 0)# dist.normalized()
						if pos.x < collide_pos.x:
							vel -= Vector2(20, 0)# -dist.normalized()
				if colliding.get_groups().has("player_horses"):
					if pos.x < collide_pos.x:
						vel = Vector2(-60, 0)


func _on_Area2D_body_enter( body ):
	colliding = body
	
	if colliding.get_groups().has("horses"):
	
		no_collision = false
	
		collide_pos = body.pos
		collide_vel = body.vel



func _on_Area2D_body_exit( body ):
	no_collision = true
