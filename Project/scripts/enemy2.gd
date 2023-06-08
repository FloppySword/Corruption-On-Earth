extends KinematicBody2D




onready var current_frame = get_node("current_frame")

export (PackedScene) var arrow1
export (PackedScene) var dead_archer1

onready var shoot_backleft = get_node("shoot_BL")
onready var shoot_left = get_node("shoot_L")
onready var shoot_backright = get_node("shoot_BR")
onready var shoot_right = get_node("shoot_R")
onready var bow_timer = get_node("bow_timer")
onready var arrow_container = get_node("arrow_container")
onready var bow_sounds = get_node("bow_sounds")
onready var death_moans = get_node("death_moans")
onready var moan_timer = get_node("moan_timer")
onready var body_container = get_node("body_container")
onready var hit_rect = get_node("hit_rect")


var pos = global_position#get_global_pos()
var vel = Vector2(0, 0)
var rot = 0
var health = global.enemy2_health
var ready_to_fire = false
var deadbodycounter = 0




func _ready():
	randomize()
	#set_fixed_process(true)
	current_frame.set_frame(0)
	current_frame.show()
	shoot_backleft.hide()
	shoot_left.hide()
	shoot_backright.hide()
	shoot_right.hide()

	
	
	
	
func _fixed_process(delta):
	
	pos = global_position
	
	var target = global.player_pos
	var target_dist = target - pos
	rot = target_dist.angle_to(Vector2(0, 1))
	#print(target, pos)
	if health > 0:
		if pos.y > 450:
			if pos.x > target.x:
				if abs(target_dist.y) > 120 and abs(target_dist.x) < 1000:
					current_frame.set_frame(1)
					shootBL()
					
				elif abs(target_dist.y) < 120:
					current_frame.set_frame(3)
					shootL()
				else: current_frame.set_frame(0)
			elif pos.x < target.x:
				if abs(target_dist.y) > 120 and abs(target_dist.x) < 1000:
					current_frame.set_frame(2)
					shootBR()
					
				elif abs(target_dist.y) < 120:
					current_frame.set_frame(4)
					shootR()
				else: current_frame.set_frame(0)
		else:
			current_frame.set_frame(0)
		
	elif health <= 0:
		current_frame.hide()
		shoot_backleft.hide()
		shoot_left.hide()
		shoot_backright.hide()
		shoot_right.hide()
		spawn_dead_body()
#		hit_rect.set_monitorable(false)
		if moan_timer.get_time_left() == 0:
			play_moan()


		
	#if pos.x > 1300 or pos.x < -100 or pos.y > 800 or pos.y < -100:
	#	queue_free()
		
		
func shootBL():
	if ready_to_fire == true:
		current_frame.hide()
		shoot_left.hide()
		shoot_backright.hide()
		shoot_right.hide()
		shoot_backleft.show()
		shoot_backleft.play()
		if shoot_backleft.get_frame() == 2:
			if bow_timer.get_time_left() == 0:
				bow_timer.start()
				var a = arrow1.instance()
				arrow_container.add_child(a)
				a.start_at(rot, pos)
				bow_sounds.play("arrow_release")

func shootL():
	if ready_to_fire == true:
		current_frame.hide()
		shoot_backleft.hide()
		shoot_backright.hide()
		shoot_right.hide()
		shoot_left.show()
		shoot_left.play()
		if shoot_left.get_frame() == 3:
			if bow_timer.get_time_left() == 0:
				bow_timer.start()
				var a = arrow1.instance()
				arrow_container.add_child(a)
				a.start_at(rot, pos)
				bow_sounds.play("arrow_release")

func shootBR():
	if ready_to_fire == true:
		current_frame.hide()
		shoot_backleft.hide()
		shoot_left.hide()
		shoot_right.hide()
		shoot_backright.show()
		shoot_backright.play()
		if shoot_backright.get_frame() == 2:
			if bow_timer.get_time_left() == 0:
				bow_timer.start()
				var a = arrow1.instance()
				arrow_container.add_child(a)
				a.start_at(rot, pos)
				bow_sounds.play("arrow_release")
				
func shootR():
	if ready_to_fire == true:
		current_frame.hide()
		shoot_backleft.hide()
		shoot_left.hide()
		shoot_backright.hide()
		shoot_right.show()
		shoot_right.play()
		if shoot_right.get_frame() == 3:
			if bow_timer.get_time_left() == 0:
				bow_timer.start()
				var a = arrow1.instance()
				arrow_container.add_child(a)
				a.start_at(rot, pos)
				bow_sounds.play("arrow_release")
	


func play_moan():
	moan_timer.start()
	if randf() > 0.2:
		var moan_selector = global.mob_moans[randi()%4]
		death_moans.play(moan_selector)

func spawn_dead_body():
	if pos.y < 750:
		if deadbodycounter <= 0:
		#if body_container.get_child_count() == 0:
			deadbodycounter = 1
			var ded = dead_archer1.instance()
			var frame = randi()%3
			body_container.add_child(ded)
			ded.init(pos, frame)

func _on_player_detector_body_enter( body ):
	if body.get_name() == "player":
		ready_to_fire = true
		#print(body.get_global_pos())



func _on_player_detector_body_exit( body ):
	if body.get_name() == "player":
		ready_to_fire = false


func _on_bow_timer_timeout():
	pass # replace with function body


func _on_hit_rect_body_enter( body ):
	if body.get_groups().has("wounds"):
		body.queue_free()
		health -= rand_range(global.gun_dmg_min, global.gun_dmg_max)
