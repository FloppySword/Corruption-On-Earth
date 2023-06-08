extends KinematicBody2D



export (PackedScene) var blood_effects
var arrow2 = preload("res://scenes/arrow.tscn")


onready var charging_anim = get_node("charging")
onready var arching_anim = get_node("arching")
onready var pounding_anim = get_node("pounding")
onready var dying_anim = get_node("dying")
onready var move_timer = get_node("move_timer")
onready var bleed_timer = get_node("bleed_timer")
onready var bow_timer = get_node("bow_timer")
onready var arrow_container = get_node("arrow_container")
onready var blood_container = get_node("blood_container")
onready var ricochet_sounds = get_node("ricochet_sounds")



var health = global.boss_health
var charging = true
var arching = false
var dying = false
var pounding = false
var pos = global_position#get_global_pos()
var target
var target_dist
var rot
var stab1
var stab2
var stab3
var player_body


func _ready():
	randomize()
	#set_fixed_process(true)
	charging_anim.show()
	arching_anim.hide()
	pounding_anim.hide()
	dying_anim.hide()
	
func _physics_process(delta):
	global.boss_health = health
	target = global.player_pos
	target_dist = target - pos
	rot = target_dist.angle_to(Vector2(0, 1))
	if dying == false:
		if charging == true:
			charge()
			if stab3 == true:
				player_body.health -= .20
			if stab2 == true:
				player_body.health -= .20
			if stab1 == true:
				player_body.health -= .20
		elif arching == true:
			arch()
		elif pounding == true:
			pound()
		if health <= 100:
			bleed()
	else:
		die()
		bleed()
		if dying_anim.get_frame() == 16:
			global.boss_has_bled = true
		
		
				
				
				
	pos = global_position#get_global_pos()				

				
			
		
func charge():
	
	if pos.x > target.x - 50:
		charging_anim.show()
		arching_anim.hide()
		pounding_anim.hide()
		if abs(pos.y - target.y) < 80:
			if pos.y > target.y - 20:
				charging_anim.set_frame(2)
			elif pos.y <= target.y - 20:
				charging_anim.set_frame(1)
		else:
			charging_anim.set_frame(0)
	else:
		move_timer.stop()
		charging = false
		pounding = true
		
func arch():
	if pos.x > target.x:
		arching_anim.show()
		charging_anim.hide()
		pounding_anim.hide()
		arching_anim.play()
		
		if arching_anim.get_frame() == 3:
			if bow_timer.get_time_left() == 0:
				bow_timer.start()
				var a = arrow2.instance()
				var choice = randi()%3
				arrow_container.add_child(a)
				a.start_at(global.arrow_dirs[choice] * rot, pos + Vector2(0, -30))
	else:
		move_timer.stop()
		arching = false
		pounding = true

func pound():
	if pos.x < target.x:
		pounding_anim.show()
		charging_anim.hide()
		arching_anim.hide()
		
	else:
		move_timer.start()
		pounding = false
		charging = true
		arching = false
		

func bleed():
	if pos.y < 750:
		var prob = randf()
		if prob < 0.5:
			var blood = blood_effects.instance()
			var frame = randi()%3
			blood_container.add_child(blood)
			blood.init(pos + Vector2(50, -80), frame)
		


func die():
	pounding_anim.hide()
	charging_anim.hide()
	arching_anim.hide()
	dying_anim.show()
	dying_anim.play()
	
func play_ricochet():
	var ricochet_selector = global.ricochets[randi()%3]
	ricochet_sounds.play(ricochet_selector)


func _on_move_timer_timeout():
	charging = not charging
	arching = not arching
	
	
func _on_lance_hit1_body_enter( body ):
	if body.get_name() == "player":
		player_body = body
		stab1 = true
		z_index = 0
		#set_z(0)
	
	


func _on_lance_hit2_body_enter( body ):
	if body.get_name() == "player":
		player_body = body
		stab2 = true
		z_index = 0
		#set_z(0)

func _on_lance_hit3_body_enter( body ):
	if body.get_name() == "player":
		player_body = body
		stab3 = true
		z_index = 0
		#set_z(0)

func _on_pound_body_enter( body ):
	pounding_anim.play()
	if pounding_anim.get_frame() == 1:
		global.player_health -= 5


func _on_arrow_range_body_enter( body ):
	pass
	

func _on_lance_hit1_body_exit( body ):
	if body.get_name() == "player":
		stab1 = false
		z_index = 2
		#set_z(2)
	


func _on_lance_hit2_body_exit( body ):
	if body.get_name() == "player":
		stab2 = false
		z_index = 2
		#set_z(2)

func _on_lance_hit3_body_exit( body ):
	if body.get_name() == "player":
		stab3 = false
		z_index = 2
		#set_z(2)

func _on_pound_body_exit( body ):
	pounding_anim.stop()


func _on_arrow_range_body_exit( body ):
	pass # replace with function body


func _on_bleed_timer_timeout():
	pass


func _on_hit_rect_body_enter( body ):
	if body.get_groups().has("wounds"):
		body.queue_free()
		randomize()
		if randf() > 0.2:
			play_ricochet()
		health -= rand_range(global.gun_dmg_min, global.gun_dmg_max)
		if health <= 0:
			dying = true
		
		
		



