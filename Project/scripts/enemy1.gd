extends KinematicBody2D

export (PackedScene) var blood_effects

onready var unscathed = get_node("unscathed")
onready var scathed_left = get_node("scathed_left")
onready var scathed_right = get_node("scathed_right")
onready var swing_timer = get_node("swing_timer")
onready var swing_delay = get_node("swing_delay")
onready var death_moans = get_node("death_moans")
onready var moan_timer = get_node("moan_timer")
onready var blood_container = get_node("blood_container")
onready var splat = get_node("splat")
onready var hit_rect = get_node("hit_rect")





var pos = global_position
var vel = Vector2(0, 0)
var health = global.enemy1_health
var e1_swing = false
var player_bleeding = false
var player = null

var prob1 = randf()
var prob2 = randf()
var prob3 = randf()
var prob4 = randf()
var prob5 = randf()



func _ready():
	randomize()
	#set_fixed_process(true)
	unscathed.show()
	scathed_left.hide()
	scathed_right.hide()
	unscathed.set_frame(0)
	scathed_right.set_frame(0)
	scathed_left.set_frame(0)
	
	
func _fixed_process(delta):
	
	
	pos = global_position 
	var target = global.player_pos
	var target_dist = target - pos
	#print(target, pos)
	if abs(target_dist.x) < 180:
		if pos.x < target.x:
			unscathed.set_frame(1)
			scathed_right.set_frame(1)
			scathed_left.set_frame(1)
		elif pos.x > target.x:
			unscathed.set_frame(3)
			scathed_right.set_frame(3)
			scathed_left.set_frame(3)
		if abs(target_dist.x) < 60 and abs(target_dist.y) < 20:
			if pos.x < target.x:
				if unscathed.get_frame() == 1:
					unscathed.set_frame(2)
				if scathed_right.get_frame() == 1:
					scathed_right.set_frame(2)
				if scathed_left.get_frame() == 1:					
					scathed_left.set_frame(2)
			elif pos.x > target.x:
				if unscathed.get_frame() == 3:
					unscathed.set_frame(4)
				if scathed_right.get_frame() == 3:
					scathed_right.set_frame(4)
				if scathed_left.get_frame() == 1:
					scathed_left.set_frame(4)
	else:
		unscathed.set_frame(0)
		scathed_right.set_frame(0)
		scathed_left.set_frame(0)
		
	
		
		
		
	if health <= 20:
		spawn_blood()
	
	if health <= 0:
		if 0 <= prob1 < 0.17:
			unscathed.set_frame(5)
		elif 0.17 <= prob1 < 0.34:
			unscathed.set_frame(6)
		elif 0.34 <= prob1 < 0.51:
			unscathed.set_frame(7)
		elif 0.51 <= prob1 < 0.68:
			unscathed.set_frame(8)
		elif 0.68 <= prob1 < 0.85:
			unscathed.set_frame(9)
		elif 0.85 <= prob1 <= 1:
			unscathed.set_frame(10)
		if prob3 >= 0.5:
			scathed_right.set_frame(5)
			scathed_left.set_frame(5)
		elif prob3 < 0.5:
			scathed_right.set_frame(6)
			scathed_left.set_frame(6)
		if moan_timer.get_time_left() == 0:
			play_moan()
		
	if swing_timer.get_time_left() == 0:
		if player_bleeding == true:
			time_swing()

func time_swing():
	swing_timer.start()
	if player != null:
		if player.current_frame.get_frame() != 21:
			global.player_health -= 10


	
func spawn_blood():
	if pos.y < 750:
		
		if prob2 > 0.5:
			
			if randf() < 0.5:
				var blood = blood_effects.instance()
				health -= 0.02
				var frame = randi()%3
				blood_container.add_child(blood)
				blood.init(pos, frame)

func play_moan():
	moan_timer.start()
	
	if prob4 > 0.2:
		var moan_selector = global.mob_moans[randi()%4]
		death_moans.play(moan_selector)
		


func lose_health():
	health -= rand_range(global.gun_dmg_min, global.gun_dmg_max)




func _on_attack_right_body_enter( body ):
	if body.get_name() == "player":
		player = body
		if body.current_frame.get_frame() != 21:
			if unscathed.get_frame() == 2: 
				player_bleeding = true
				splat.set_global_pos(body.get_global_pos())
				splat.set_emitting(true)
#		
	
			

func _on_attack_left_body_enter( body ):
	if body.get_name() == "player":
		player = body
		if body.current_frame.get_frame() != 21:
			if unscathed.get_frame() == 4:
				player_bleeding = true
				splat.set_global_pos(body.get_global_pos())
				splat.set_emitting(true)
#			
		#print(body.current_frame.get_frame())
			


func _on_hit_rect_body_enter( body ):
	if body.get_groups().has("wounds"):
		health -= rand_range(global.gun_dmg_min, global.gun_dmg_max)
		body.queue_free()
	
		
func _on_attack_left_body_exit( body ):
	if body.get_name() == "player":
		player_bleeding = false
		
func _on_attack_right_body_exit( body ):
	if body.get_name() == "player":
		player_bleeding = false
	
