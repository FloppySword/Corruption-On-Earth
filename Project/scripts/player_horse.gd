extends KinematicBody2D


var pos = Vector2(700, 100)
var vel = Vector2(0, 0)
var acc = Vector2(0, 0)
var rot = 0
var no_collision = true
var collide_pos = null
var collide_vel = null
var colliding = null
var fast_gallop = false
var stop_moving = false
onready var player = get_node("player")
onready var animation = get_node("animation")
onready var gallop_sound = get_node("gallop")
onready var sample_timer = get_node("sample_timer")

func _ready():
	global_position = pos
	

func _input(event):

	#if (ev.type==InputEvent.MOUSE_BUTTON):
		#print("Mouse Click/Unclick at: ",ev.pos)
	if event is InputEventMouseMotion:
		#print("Mouse Motion at: ",ev.pos)
		#print(ev.pos - pos)
		var target_dist = event.global_position - pos
		rot = target_dist.angle_to(Vector2(0, 1))
		player.rot = rot
		player.mouse_pos = event.global_position
	if event is InputEventKey:
		if event.is_action_released("ui_down"):
			animation.get_sprite_frames().set_animation_speed("default", 10)
	
func _physics_process(delta):
	play_gallop()
	fast_gallop = false
	if stop_moving == false:
		if Input.is_action_pressed("ui_left"):
			vel = Vector2(-150, 0)
			animation.get_sprite_frames().set_animation_speed("default", 10)
		else: vel = Vector2(0, 0)
		if Input.is_action_pressed("ui_right"):
			vel = Vector2(150, 0)
			animation.get_sprite_frames().set_animation_speed("default", 10)
		if Input.is_action_pressed("ui_up"):
			vel = Vector2(0, -119)
			animation.get_sprite_frames().set_animation_speed("default", 8)
		if Input.is_action_pressed("ui_down"):
			vel = Vector2(0, 200)
			animation.get_sprite_frames().set_animation_speed("default", 12)
			fast_gallop = true
			#print(animation.get_sprite_frames().get_animation_speed("player_horse"))
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
			vel = Vector2(-100, -100)
			animation.get_sprite_frames().set_animation_speed("default", 10)
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_down"):
			vel = Vector2(-100, 100)
			animation.get_sprite_frames().set_animation_speed("default", 10)
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_up"):
			vel = Vector2(100, -100)
			animation.get_sprite_frames().set_animation_speed("default", 10)
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
			vel = Vector2(100, 100)
			animation.get_sprite_frames().set_animation_speed("default", 10)
	#elif stop_moving == true:
		
	
	avoid_horses()

	vel += acc * delta
	pos += vel * delta + 0.5 * acc * delta*delta

	global_position = pos
	"""
	update above, and not just here but on all horse scenes, to move_and_slide or collide
	"""
	
	
	global.playerhorse_pos = pos
	global.playerhorse_vel = vel
	#print(global.target)
	
	if pos.x > 1175:
		pos.x = 1175
	if pos.x < 25:
		pos.x = 25
	if pos.y > 610:
		pos.y = 610
	if pos.y < 50:
		pos.y = 50
	

func play_gallop():
	if sample_timer.get_time_left() == 0:
		sample_timer.start()
		if fast_gallop == false:
			pass
			#gallop_sound.play("horse_gallop_final")
		elif fast_gallop == true:
			pass
			#gallop_sound.play("horse_gallop_fast")
			#	
func avoid_horses():
	if 10 < pos.x && pos.x < 1190:
		for horse in get_tree().get_nodes_in_group("horses"):
			if horse != self:
				var avoid_dist = pos - horse.pos
				if avoid_dist.length() < 150:
					if abs(avoid_dist.x) < 25:
						if pos.x > horse.pos.x:
							vel.x = horse.vel.x + 20
						if pos.x < horse.pos.x:
							vel.x = horse.vel.x - 20
						if abs(avoid_dist.y) < 15:
							if pos.y > horse.pos.y:
								vel.y = horse.vel.y + 20
							if pos.y < horse.pos.y:
								vel.y = horse.vel.y - 20
		for horse in get_tree().get_nodes_in_group("lancerhorses"):
			if horse != self:
				var avoid_dist = pos - horse.pos
				if avoid_dist.length() < 30:
					stop_moving = true
				else:
					stop_moving = false
				if avoid_dist.length() < 150:
					if abs(avoid_dist.x) < 25:
						if pos.x > horse.pos.x:
							vel.x = -horse.vel.x + 20
						elif pos.x <= horse.pos.x:
							vel.x = -horse.vel.x - 20
	
#	if colliding != null:
#		#print(colliding.get_name())
#		if colliding != self:
#			if no_collision == false:
#				if colliding.get_groups().has("horses"):
#				
							
#					if pos.x > colliding.pos.x:
#						vel.x = 10
#					elif pos.x < colliding.pos.x:
#						vel.x = -10
#					
					
					
#					
#					if 0 < dist.length() < 50:
#						if pos.x > collide_pos.x:
#							vel += Vector2(150, 0)
#						if pos.x < collide_pos.x:
#							vel -= Vector2(150, 0)
#					if dist.length() < 10:
#						if pos.x > collide_pos.x:
#							#vel += Vector2(300, 0)
#							colliding.vel = vel
#						if pos.x < collide_pos.x:
#							#vel -= Vector2(300, 0)
#							colliding.vel = vel



func _on_Area2D_body_enter( body ):
	#print(body.get_name())
	if not body.get_groups().has("arrows"):
		if not body.get_groups().has("bullets"):
			if not body.get_groups().has("enemies"):
				if body.get_groups().has("horses"):
					colliding = body
					no_collision = false

#					colliding = body
#					no_collision = false
#					collide_pos = body.get_pos()
#					collide_vel = body.vel
#					if abs(collide_vel.x) > 5:
#						collide_vel.x *= -1
#					else:
#						collide_vel.x = vel.x + 5
			#elif colliding.get_groups().has("enemies"):
			#	null


func _on_Area2D_body_exit( body ):
	#var node_ref = weakref(body)
	#if node_ref.get_ref() != null:
	if body.get_groups().has("horses"):
		no_collision = true
	#else:
	 #    print("Node has been deleted")
		
		
		


func _on_left_flank_body_enter( body ):
	if not body.get_groups().has("player_horses"):
		if body.get_groups().has("horses"):
			pass


func _on_left_flank_body_exit( body ):
	if not body.get_groups().has("player_horses"):
		if body.get_groups().has("horses"):
			pass


func _on_right_flank_body_enter( body ):
	if not body.get_groups().has("player_horses"):
		if body.get_groups().has("horses"):
			pass


func _on_right_flank_body_exit( body ):
	if not body.get_groups().has("player_horses"):
		if body.get_groups().has("horses"):
			pass
