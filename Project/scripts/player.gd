extends KinematicBody2D

signal hit
signal wound_enemy



onready var current_frame = get_node("current_frame")
onready var current_frame2 = get_node("current_frame2")
onready var reload_AR_anim = get_node("reload_AR_anim")
onready var reload_pistol_anim = get_node("reload_pistol_anim")


export (PackedScene) var muzzle_flash1

var gunshot_wound = preload("res://scenes/gunshot_wound.tscn")
var bullet_trail = preload("res://scenes/bullet_trail.tscn")

onready var bullet_pos0 = get_node("pos0")
onready var bullet_pos1 = get_node("pos1")
onready var bullet_pos2 = get_node("pos2")
onready var bullet_pos3 = get_node("pos3")
onready var bullet_pos4 = get_node("pos4")
onready var bullet_pos5 = get_node("pos5")
onready var bullet_pos6 = get_node("pos6")
onready var bullet_pos7 = get_node("pos7")
onready var bullet_pos8 = get_node("pos8")
onready var bullet_pos9 = get_node("pos9")
onready var bullet_pos10 = get_node("pos10")
onready var bullet_pos11 = get_node("pos11")
onready var bullet_pos12 = get_node("pos12")
onready var bullet_pos13 = get_node("pos13")
onready var bullet_pos14 = get_node("pos14")
onready var bullet_pos15 = get_node("pos15")
onready var bullet_pos16 = get_node("pos16")
onready var bullet_pos17 = get_node("pos17")
onready var bullet_pos18 = get_node("pos18")
onready var bullet_pos19 = get_node("pos19")
onready var bullet_pos20 = get_node("pos20")
onready var bullet_pos21 = get_node("pos21")
onready var bullet_pos22 = get_node("pos22")
onready var bullet_pos23 = get_node("pos23")
onready var bullet_pos24 = get_node("pos24")
onready var bullet_pos25 = get_node("pos25")
onready var bullet_pos26 = get_node("pos26")
onready var bullet_pos27 = get_node("pos27")
onready var bullet_pos28 = get_node("pos28")
onready var bullet_pos29 = get_node("pos29")
onready var bullet_pos30 = get_node("pos30")
onready var bullet_pos31 = get_node("pos31")
onready var bullet_pos32 = get_node("pos32")
onready var bullet_pos33 = get_node("pos33")
onready var bullet_pos34 = get_node("pos34")
onready var bullet_pos35 = get_node("pos35")
onready var bullet_pos36 = get_node("pos36")
onready var bullet_pos37 = get_node("pos37")
onready var bullet_pos38 = get_node("pos38")




#onready var reticule = get_node("reticule")

onready var shape = get_node("shape")

onready var shoot_ray = get_node("shoot_ray")

#onready var hit_enemy_timer = get_node("hit_enemy_timer")
onready var AR_timer = get_node("AR_timer")
onready var pistol_timer = get_node("pistol_timer")
onready var bleeding_timer = get_node("bleeding_timer")
onready var grunt_timer = get_node("grunt_timer")
onready var player_sounds = get_node("player_sounds")
onready var gun_sounds = get_node("gun_sounds")
onready var pistol_sound = get_node("pistol_sound")
onready var reload_AR_sound = get_node("reload_AR_sound")
onready var reload_pistol_sound = get_node("reload_pistol_sound")
onready var dodge_cooldown= get_node("dodge_cooldown")



var frame = 0
var bullet_pos
var screen_size = Vector2()
var rot = 0
var pos = global_position
var vel = Vector2()
var health = global.player_health
var locked = false
var hit_location = Vector2()
var target_enemy = null
var ar_selected = true
var pistol_selected = false
var AR_ammo = 0
var pistol_ammo = 0
var reloading = false
var dodging = false

var mouse_pos = Vector2()


func _ready():
	current_frame.show()
	current_frame2.hide()
	reload_AR_anim.hide()
	reload_pistol_anim.hide()
	randomize()

	#screen_size = get_viewport_rect().size
	#pos = screen_size / 2
	#set_pos(pos)




func _physics_process(delta):
	
	frame = current_frame.get_frame()
	current_frame2.set_frame(frame)
	
#	print(mouse_pos)

	print(current_frame.get_frame())
	
	if reloading == false:
		if .25 >= rot and rot > .125:
			current_frame.set_frame(1)
			rot = .20
			bullet_pos = bullet_pos1
		elif .418 >= rot and rot > .25:
			current_frame.set_frame(2)
			rot = .40
			bullet_pos = bullet_pos2
		elif .585 >= rot and rot > .418:
			current_frame.set_frame(3)
			rot = .57
			bullet_pos = bullet_pos3
		elif .793 >= rot and rot > .585:
			current_frame.set_frame(4)
			rot = .70
			bullet_pos = bullet_pos4
		elif 1.00 >= rot and rot > .793:
			current_frame.set_frame(5)
			rot = .95
			bullet_pos = bullet_pos5
		elif 1.175 >= rot and rot > 1.00:
			current_frame.set_frame(6)
			rot = 1.10
			bullet_pos = bullet_pos6
		elif 1.35 >= rot and rot > 1.175:
			current_frame.set_frame(7)
			rot = 1.35
			bullet_pos = bullet_pos7
		elif 1.425 >= rot and rot > 1.35:
			current_frame.set_frame(8)
			rot = 1.42
			bullet_pos = bullet_pos8
		elif 1.50 >= rot and rot > 1.425:
			current_frame.set_frame(9)
			rot = 1.50
			bullet_pos = bullet_pos9
		elif 1.575 >= rot and rot > 1.50:
			current_frame.set_frame(10)
			rot = 1.575
			bullet_pos = bullet_pos10
		elif 1.66 >= rot and rot > 1.575:
			current_frame.set_frame(11)
			rot= 1.625
			bullet_pos = bullet_pos11
		elif 1.74 >= rot and rot > 1.66:
			current_frame.set_frame(12)
			rot = 1.70
			bullet_pos = bullet_pos12
		elif 1.82 >= rot and rot > 1.74:
			current_frame.set_frame(13)
			rot = 1.80
			bullet_pos = bullet_pos13
		elif 1.90 >= rot and rot > 1.82:
			current_frame.set_frame(14)
			rot = 1.90
			bullet_pos = bullet_pos14
		elif 2.07 >= rot and rot > 1.90:
			current_frame.set_frame(15)
			rot = 2.00
			bullet_pos = bullet_pos15	
		elif 2.24 >= rot and rot > 2.07:
			current_frame.set_frame(16)
			rot = 2.15
			bullet_pos = bullet_pos16
		elif 2.41 >= rot and rot > 2.24:
			current_frame.set_frame(17)
			rot = 2.39
			bullet_pos = bullet_pos17
		elif 2.52 >= rot and rot > 2.41:
			current_frame.set_frame(18)
			rot = 2.50
			bullet_pos = bullet_pos18
		elif 2.63 >= rot and rot > 2.52:
			rot = 2.60
			bullet_pos = bullet_pos19
		elif 2.75 >= rot and rot > 2.63:
			rot = 2.75
			bullet_pos = bullet_pos20
		elif (3.15 >= rot and rot > 2.75) or (-3.15 <= rot and rot < -2.75):
			current_frame.set_frame(21)
			rot = 3.00
			bullet_pos = bullet_pos21
		elif -2.75 <= rot and rot < -2.49:
			current_frame.set_frame(22)
			rot = -2.70
			bullet_pos = bullet_pos22
		elif -2.49 <= rot and rot < -2.23:
			current_frame.set_frame(23)
			rot = -2.40
			bullet_pos = bullet_pos23
		elif -2.23 <= rot and rot < -1.95:
			current_frame.set_frame(24)
			rot = -2.20
			bullet_pos = bullet_pos24
		elif -1.95 <= rot and rot < -1.84:
			current_frame.set_frame(25)
			rot = -1.95
			bullet_pos = bullet_pos25
		elif -1.84 <= rot and rot < -1.73:
			current_frame.set_frame(26)
			rot = -1.84
			bullet_pos = bullet_pos26
		elif -1.73 <= rot and rot < -1.63:
			current_frame.set_frame(27)
			rot = -1.70
			bullet_pos = bullet_pos27
		elif -1.63 <= rot and rot < -1.48:
			current_frame.set_frame(28)
			rot = -1.58
			bullet_pos = bullet_pos28
		elif -1.48 <= rot and rot < -1.33:
			current_frame.set_frame(29)
			rot = -1.45
			bullet_pos = bullet_pos29
		elif -1.33 <= rot and rot < -1.18:
			current_frame.set_frame(30)
			rot = -1.33
			bullet_pos = bullet_pos30
		elif -1.18 <= rot and rot < -1.00:
			current_frame.set_frame(31)
			rot = -1.12
			bullet_pos = bullet_pos31
		elif -1.00 <= rot and rot < -.825:
			current_frame.set_frame(32)
			rot = -1.00
			bullet_pos = bullet_pos32
		elif -.825 <= rot and rot < -.688:
			current_frame.set_frame(33)
			rot = -.80
			bullet_pos = bullet_pos33
		elif -.688 <= rot and rot < -.55:
			current_frame.set_frame(34)
			rot = -.65
			bullet_pos = bullet_pos34
		elif -.55 <= rot and rot < -.46:
			current_frame.set_frame(35)
			rot = -.55
			bullet_pos = bullet_pos35
		elif -.46 <= rot and rot < -.32:
			current_frame.set_frame(36)
			rot = -.45
			bullet_pos = bullet_pos36
		elif -.32 <= rot and rot < -.08:
			current_frame.set_frame(37)
			rot = -.225
			bullet_pos = bullet_pos37
		
		
		else:
			current_frame.set_frame(0)
			rot = 0
			bullet_pos = bullet_pos0

	if current_frame.get_frame() == 1:
		shoot_ray.rotation_degrees = (-1075)

	elif current_frame.get_frame() == 2:
		#shoot_ray.set_pos(Vector2(-28.69189, 40.36578))
		shoot_ray.rotation_degrees = (-1100)
		
	elif current_frame.get_frame() == 3:
		shoot_ray.rotation_degrees = (-1112.5)
	
	elif current_frame.get_frame() == 4:
		#shoot_ray.set_pos(Vector2(-46.50323, 31.31408))
		shoot_ray.rotation_degrees = (-1125)
		
	elif current_frame.get_frame() == 5:
		shoot_ray.rotation_degrees = (-1142.5)
		
	elif current_frame.get_frame() == 6:
		#shoot_ray.set_pos(Vector2(-61.31243, 12.09057))
		shoot_ray.rotation_degrees = (-1160)
		
	elif current_frame.get_frame() == 7:
		shoot_ray.rotation_degrees = (-1165)
	
	elif current_frame.get_frame() == 8:
		#shoot_ray.set_pos(Vector2(-63.4142, -5.072266))
		shoot_ray.rotation_degrees = (-1170)
		
	elif current_frame.get_frame() == 9:
		shoot_ray.rotation_degrees = (-1175)
	elif current_frame.get_frame() == 10:
		shoot_ray.rotation_degrees = (-1180)
	elif current_frame.get_frame() == 11: 
		shoot_ray.rotation_degrees = (-1185)
		
	elif current_frame.get_frame() == 12:
		#shoot_ray.set_pos(Vector2(-61.2834, -32.35424))
		shoot_ray.rotation_degrees = (-1190)
	
	elif current_frame.get_frame() == 13: 
		shoot_ray.rotation_degrees = (-1197)
	elif current_frame.get_frame() == 14: 
		shoot_ray.rotation_degrees = (-1204)
		
	elif current_frame.get_frame() == 15:
		#shoot_ray.set_pos(Vector2(-45.72399, -55.25637))
		shoot_ray.rotation_degrees = (-1212)
		
	elif current_frame.get_frame() == 16: 
		shoot_ray.rotation_degrees = (-1221)
	elif current_frame.get_frame() == 17:
		shoot_ray.rotation_degrees = (-1230)
		
	elif current_frame.get_frame() == 18:
		#shoot_ray.set_pos(Vector2(-25.80310, -71.52819))
		shoot_ray.rotation_degrees = (-1240)
	elif current_frame.get_frame() == 19:
		shoot_ray.rotation_degrees = (-1245)
	elif current_frame.get_frame() == 20: 
		shoot_ray.rotation_degrees = (-1250)
		
	elif current_frame.get_frame() == 21:
		#shoot_ray.set_pos(Vector2(-4.34991, -78.18737))
		shoot_ray.rotation_degrees = (-1255)
		
	elif current_frame.get_frame() == 22:
		#shoot_ray.set_pos(Vector2(40.06341, -30.13507))
		shoot_ray.rotation_degrees = (-1305)
	elif current_frame.get_frame() == 23: 
		shoot_ray.rotation_degrees = (-1311)
	elif current_frame.get_frame() == 24: 
		shoot_ray.rotation_degrees = (-1318)
		
	elif current_frame.get_frame() == 25:
		#shoot_ray.set_pos(Vector2(45.11938, -13.94439))
		shoot_ray.rotation_degrees = (-1325)
		
	elif current_frame.get_frame() == 26:
		shoot_ray.rotation_degrees = (-1333)
	elif current_frame.get_frame() == 27: 
		shoot_ray.rotation_degrees = (-1341)
	elif current_frame.get_frame() == 28:
		#shoot_ray.set_pos(Vector2(47.32342, .950684))
		shoot_ray.rotation_degrees = (-1350)
	elif current_frame.get_frame() == 29:
		shoot_ray.rotation_degrees = (-1358)
	elif current_frame.get_frame() == 30: 
		shoot_ray.rotation_degrees = (-1366)
	
		
	elif current_frame.get_frame() == 31:
		#shoot_ray.set_pos(Vector2(40.21673, 17.94784))
		shoot_ray.rotation_degrees = (-1375)
		
	elif current_frame.get_frame() == 32:
		shoot_ray.rotation_degrees = (-1385)
		
	elif current_frame.get_frame() == 33:
		#shoot_ray.set_pos(Vector2(29.0479, 27.83776))
		shoot_ray.rotation_degrees = (-1395)
	elif current_frame.get_frame() == 34:
		shoot_ray.rotation_degrees = (-1402.5)
		
	elif current_frame.get_frame() == 35:
		#shoot_ray.set_pos(Vector2(19.23718, 36.27307))
		shoot_ray.rotation_degrees = (-1410)
		
	elif current_frame.get_frame() == 36:
		shoot_ray.rotation_degrees = (-1418.5)
	elif current_frame.get_frame() == 37:
		#shoot_ray.set_pos(Vector2(6.486389, 38.90353))
		shoot_ray.rotation_degrees = (-1425)
		

	elif current_frame.get_frame() == 0:
		#shoot_ray.set_pos(Vector2(-8.467651, 42.693176))
		shoot_ray.rotation_degrees = (0)
	

	
	if reload_pistol_anim.is_playing() == false:
		if reload_AR_anim.is_playing() == false:
			if dodging == false:
				if Input.is_action_pressed("player_shoot"):
				
					if ar_selected == true:
						if AR_timer.get_time_left() == 0:
							shoot_AR()
					elif pistol_selected == true:
						if pistol_timer.get_time_left() == 0:
							shoot_pistol()



#	if Input.is_action_pressed("raycast_test_shoot"):
#		if locked == true:
#			splatter()
			
	
	if Input.is_action_pressed("player_evade"):
		if dodge_cooldown.get_time_left() == 0:
			current_frame.set_frame(44)
			dodging = true
	if Input.is_action_pressed("player_evade") == false:
		if dodging == true:
			dodge_cooldown.start()
		dodging = false
		
		
		
	if Input.is_action_pressed("select_AR"):
		if reload_AR_anim.is_playing() == false:
			if reload_pistol_anim.is_playing() == false:
				ar_selected = true
				pistol_selected = false
				global.AR_active = true
				global.pistol_active = false
				current_frame2.hide()
				reload_pistol_anim.hide()
				current_frame.show()
		
	if Input.is_action_pressed("select_pistol"):
		if reload_pistol_anim.is_playing() == false:
			if reload_AR_anim.is_playing() == false:
				ar_selected = false
				pistol_selected = true
				global.AR_active = false
				global.pistol_active = true
				current_frame.hide()
				reload_AR_anim.hide()
				current_frame2.show()
			
	pos = global_position
	#print(pos)
	global.player_pos = pos
	
	
	if global.player_bleeding == true:
		if grunt_timer.get_time_left() == 0:	
			player_grunt()
	
	health = global.player_health
			
	if locked == true:
		if target_enemy != null:
			hit_location = target_enemy.get_global_pos()
			#print(hit_location)
		

		
		
		
		
		


func player_grunt():	
		grunt_timer.start()
		var grunt_choice = global.player_grunts[randi()%5]
		#player_sounds.play(grunt_choice)

func shoot_AR():
	AR_timer.start()
	var gunshot_choice = global.gunshots[randi()%3]
	var prob = randf()
	if prob > 0.05:
		var m = muzzle_flash1.instance()
		add_child(m)
		m.init(rot, bullet_pos.global_position)
	#gun_sounds.play(gunshot_choice)
	if shoot_ray.is_colliding():
		var shot_dist = (shoot_ray.get_collision_point() - bullet_pos.global_position).length()
		if shot_dist >= 110:
			emit_signal("hit", bullet_pos.global_position, shoot_ray.get_collision_point())
		emit_signal("wound_enemy", shoot_ray.get_collision_point())
	else:
		var trail = bullet_trail.instance()
		add_child(trail)
		trail.global_position = (bullet_pos.global_position)
		trail.region_rect = (Rect2(0, 0, 1200, 2))

		trail.global_rotation = (shoot_ray.global_rotation - PI/2)
	AR_ammo += 1
	if AR_ammo / 15 == 1:
		reloading = true
		reload_AR()
		AR_ammo = 0
		
func shoot_pistol():
	pistol_timer.start()
	#pistol_sound.play("pistol_shot")
	
	if shoot_ray.is_colliding():
		emit_signal("hit", bullet_pos.get_global_pos(), shoot_ray.get_collision_point())
		emit_signal("wound_enemy", shoot_ray.get_collision_point())
	else:
		var trail = bullet_trail.instance()
		add_child(trail)
		trail.global_position = (bullet_pos.global_position)
		trail.region_rect = Rect2(0, 0, 1200, 2)

		trail.global_rotation = (shoot_ray.get_rot() - PI/2)
	pistol_ammo += 1
	if pistol_ammo / 8 == 1:
		reloading = true
		reload_pistol()
		pistol_ammo = 0

func reload_AR():
	reloading = true
	current_frame.hide()
	reload_AR_anim.show()
	reload_AR_anim.play()
	#reload_AR_sound.play("reload_AR")
	
		
func reload_pistol():
	reloading = true
	current_frame2.hide()
	reload_pistol_anim.show()
	reload_pistol_anim.play()
	#reload_pistol_sound.play("reload_pistol")
		


func _on_reload_pistol_anim_finished():
	reload_pistol_anim.stop()
	reload_pistol_anim.hide()
	reload_pistol_anim.set_frame(0)
	current_frame2.show()
	reloading = false



func _on_reload_AR_anim_finished():
	reload_AR_anim.stop()
	reload_AR_anim.hide()
	reload_AR_anim.set_frame(0)
	current_frame.show()
	reloading = false
