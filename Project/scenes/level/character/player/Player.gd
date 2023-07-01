extends KinematicBody2D


#signal hit
#signal wound_enemy

signal shoot
signal hoof_step
signal game_over
signal health_changed
signal set_aim_dir
signal set_move_dir
signal ammo_changed

onready var player_anim_sprite = $PlayerArea2D/PlayerAnimatedSprite
onready var current_frame = 0


var muzzle_flash1 = preload("res://scenes/level/character/player/muzzle_flash.tscn")
#var gunshot_wound = preload("res://scenes/gunshot_wound.tscn")
#var bullet_trail = preload("res://scenes/bullet_trail.tscn")

var KickImpact = preload("res://scenes/level/character/KickImpact.tscn")
var BloodImpact = preload("res://scenes/level/character/BloodEffect.tscn")

onready var bullet_pos0 = get_node("PlayerArea2D/MuzzlePositions/pos0")
onready var bullet_pos1 = get_node("PlayerArea2D/MuzzlePositions/pos1")
onready var bullet_pos2 = get_node("PlayerArea2D/MuzzlePositions/pos2")
onready var bullet_pos3 = get_node("PlayerArea2D/MuzzlePositions/pos3")
onready var bullet_pos4 = get_node("PlayerArea2D/MuzzlePositions/pos4")
onready var bullet_pos5 = get_node("PlayerArea2D/MuzzlePositions/pos5")
onready var bullet_pos6 = get_node("PlayerArea2D/MuzzlePositions/pos6")
onready var bullet_pos7 = get_node("PlayerArea2D/MuzzlePositions/pos7")
onready var bullet_pos8 = get_node("PlayerArea2D/MuzzlePositions/pos8")
onready var bullet_pos9 = get_node("PlayerArea2D/MuzzlePositions/pos9")
onready var bullet_pos10 = get_node("PlayerArea2D/MuzzlePositions/pos10")
onready var bullet_pos11 = get_node("PlayerArea2D/MuzzlePositions/pos11")
onready var bullet_pos12 = get_node("PlayerArea2D/MuzzlePositions/pos12")
onready var bullet_pos13 = get_node("PlayerArea2D/MuzzlePositions/pos13")
onready var bullet_pos14 = get_node("PlayerArea2D/MuzzlePositions/pos14")
onready var bullet_pos15 = get_node("PlayerArea2D/MuzzlePositions/pos15")
onready var bullet_pos16 = get_node("PlayerArea2D/MuzzlePositions/pos16")
onready var bullet_pos17 = get_node("PlayerArea2D/MuzzlePositions/pos17")
onready var bullet_pos18 = get_node("PlayerArea2D/MuzzlePositions/pos18")
onready var bullet_pos19 = get_node("PlayerArea2D/MuzzlePositions/pos19")
onready var bullet_pos20 = get_node("PlayerArea2D/MuzzlePositions/pos20")
onready var bullet_pos21 = get_node("PlayerArea2D/MuzzlePositions/pos21")
onready var bullet_pos22 = get_node("PlayerArea2D/MuzzlePositions/pos22")
onready var bullet_pos23 = get_node("PlayerArea2D/MuzzlePositions/pos23")
onready var bullet_pos24 = get_node("PlayerArea2D/MuzzlePositions/pos24")
onready var bullet_pos25 = get_node("PlayerArea2D/MuzzlePositions/pos25")
onready var bullet_pos26 = get_node("PlayerArea2D/MuzzlePositions/pos26")
onready var bullet_pos27 = get_node("PlayerArea2D/MuzzlePositions/pos27")
onready var bullet_pos28 = get_node("PlayerArea2D/MuzzlePositions/pos28")
onready var bullet_pos29 = get_node("PlayerArea2D/MuzzlePositions/pos29")
onready var bullet_pos30 = get_node("PlayerArea2D/MuzzlePositions/pos30")
onready var bullet_pos31 = get_node("PlayerArea2D/MuzzlePositions/pos31")
onready var bullet_pos32 = get_node("PlayerArea2D/MuzzlePositions/pos32")
onready var bullet_pos33 = get_node("PlayerArea2D/MuzzlePositions/pos33")
onready var bullet_pos34 = get_node("PlayerArea2D/MuzzlePositions/pos34")
onready var bullet_pos35 = get_node("PlayerArea2D/MuzzlePositions/pos35")
onready var bullet_pos36 = get_node("PlayerArea2D/MuzzlePositions/pos36")
onready var bullet_pos37 = get_node("PlayerArea2D/MuzzlePositions/pos37")
onready var bullet_pos38 = get_node("PlayerArea2D/MuzzlePositions/pos38")


#onready var reticule = get_node("reticule")

#onready var shape = get_node("shape")

#onready var shoot_ray = get_node("shoot_ray")

#onready var hit_enemy_timer = get_node("hit_enemy_timer")
#onready var AR_timer = get_node("AR_timer")
#onready var pistol_timer = get_node("pistol_timer")
onready var bleeding_timer = get_node("bleeding_timer")
#onready var grunt_timer = get_node("grunt_timer")
#onready var player_sounds = get_node("player_sounds")
#onready var gun_sounds = get_node("gun_sounds")
##onready var pistol_sound = get_node("pistol_sound")
#onready var reload_AR_sound = get_node("reload_AR_sound")
#onready var reload_pistol_sound = get_node("reload_pistol_sound")
onready var dodge_cooldown= get_node("dodge_cooldown")

onready var shoot_pos_left = $ChasePositions/LeftShooting
onready var kick_pos_left = $ChasePositions/LeftKicking
onready var shoot_pos_right = $ChasePositions/RightShooting
onready var kick_pos_right = $ChasePositions/RightKicking

onready var player_hitbox = $PlayerArea2D
onready var horse_bullet_hitbox = $HorseBulletDamageArea2D
onready var horse_kick_hitbox = $HorseKickDamageArea2D

var frame = 0
var bullet_pos = Vector2.ZERO
var screen_size = Vector2()
var rot = 0
var pos = Vector2.ZERO
var vel = Vector2()
var locked = false
var hit_location = Vector2()
var target_enemy = null
var ar_selected = true
var pistol_selected = false
var AR_ammo = 0
var pistol_ammo = 0
var reloading = false
var dodging = false
var leverAction = false

var frames_aiming_front = [0, 1, 2, 3, 4, 5, 34, 35, 36, 37, 38]
var frames_aiming_left = [6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
var frames_aiming_right = [22,23,24,25,26,27,28,29,30,31,32,33]

var mouse_pos = Vector2()


func _ready():
	pos = global_position
	player_anim_sprite.animation = "default"
	$AnimationPlayer.play("HorseGallop")

	randomize()
	Global.player = self
	
	$PlayerArea2D/PlayerCollisionShape2D.disabled = false
	

func _input(event):
	

	if event is InputEventMouseMotion && Global.device == "PC":
		mouse_pos = get_global_mouse_position()
		if mouse_pos.y > Global.mouse_max_y:
			return
		var target_dist = mouse_pos - global_position
		rot = -target_dist.angle_to(Vector2(0, 1))
		
	if event is InputEventKey:
		if event.is_action_released("ui_down"):
			pass

func hoof_step(right_hoof:bool):
	var hoof_pos = global_position
	if right_hoof:
		hoof_pos += Vector2(5, 10)
	else:
		hoof_pos += Vector2(-5, 10)
	
	emit_signal("hoof_step", hoof_pos, "hoof")
	
	
func get_player_direction():
#	if leverAction:
#		return
	if player_anim_sprite.animation == "default":
		if Global.device == "Mobile":
			rot = Global.joystick_rot
		if .25 >= rot and rot > .125:
			player_anim_sprite.frame = 1
			rot = .20
			bullet_pos = bullet_pos1.global_position
		elif .418 >= rot and rot > .25:
			player_anim_sprite.frame = 2
			rot = .40
			bullet_pos = bullet_pos2.global_position
		elif .585 >= rot and rot > .418:
			player_anim_sprite.frame = 3
			rot = .57
			bullet_pos = bullet_pos3.global_position
		elif .793 >= rot and rot > .585:
			player_anim_sprite.frame = 4
			rot = .70
			bullet_pos = bullet_pos4.global_position
		elif 1.00 >= rot and rot > .793:
			player_anim_sprite.frame = 5
			rot = .95
			bullet_pos = bullet_pos5.global_position
		elif 1.175 >= rot and rot > 1.00:
			player_anim_sprite.frame = 6
			rot = 1.10
			bullet_pos = bullet_pos6.global_position
		elif 1.35 >= rot and rot > 1.175:
			player_anim_sprite.frame = 7
			rot = 1.35
			bullet_pos = bullet_pos7.global_position
		elif 1.425 >= rot and rot > 1.35:
			player_anim_sprite.frame = 8
			rot = 1.42
			bullet_pos = bullet_pos8.global_position
		elif 1.50 >= rot and rot > 1.425:
			player_anim_sprite.frame = 9
			rot = 1.50
			bullet_pos = bullet_pos9.global_position
		elif 1.575 >= rot and rot > 1.50:
			player_anim_sprite.frame = 10
			rot = 1.575
			bullet_pos = bullet_pos10.global_position
		elif 1.66 >= rot and rot > 1.575:
			player_anim_sprite.frame = 11
			rot= 1.625
			bullet_pos = bullet_pos11.global_position
		elif 1.74 >= rot and rot > 1.66:
			player_anim_sprite.frame = 12
			rot = 1.70
			bullet_pos = bullet_pos12.global_position
		elif 1.82 >= rot and rot > 1.74:
			player_anim_sprite.frame = 13
			rot = 1.80
			bullet_pos = bullet_pos13.global_position
		elif 1.90 >= rot and rot > 1.82:
			player_anim_sprite.frame = 14
			rot = 1.90
			bullet_pos = bullet_pos14.global_position
		elif 2.07 >= rot and rot > 1.90:
			player_anim_sprite.frame = 15
			rot = 2.00
			bullet_pos = bullet_pos15.global_position	
		elif 2.24 >= rot and rot > 2.07:
			player_anim_sprite.frame = 16
			rot = 2.15
			bullet_pos = bullet_pos16.global_position
		elif 2.41 >= rot and rot > 2.24:
			player_anim_sprite.frame = 17
			rot = 2.39
			bullet_pos = bullet_pos17.global_position
		elif 2.52 >= rot and rot > 2.41:
			player_anim_sprite.frame = 18
			rot = 2.50
			bullet_pos = bullet_pos18.global_position
		elif 2.63 >= rot and rot > 2.52:
			rot = 2.60
			bullet_pos = bullet_pos19.global_position
		elif 2.75 >= rot and rot > 2.63:
			rot = 2.75
			bullet_pos = bullet_pos20.global_position
		elif (3.15 >= rot and rot > 2.75) or (-3.15 <= rot and rot < -2.75):
			player_anim_sprite.frame = 21
			rot = 3.00
			bullet_pos = bullet_pos21.global_position
		elif -2.75 <= rot and rot < -2.49:
			player_anim_sprite.frame = 22
			rot = -2.70
			bullet_pos = bullet_pos22.global_position
		elif -2.49 <= rot and rot < -2.23:
			player_anim_sprite.frame = 23
			rot = -2.40
			bullet_pos = bullet_pos23.global_position
		elif -2.23 <= rot and rot < -1.95:
			player_anim_sprite.frame = 24
			rot = -2.20
			bullet_pos = bullet_pos24.global_position
		elif -1.95 <= rot and rot < -1.84:
			player_anim_sprite.frame = 25
			rot = -1.95
			bullet_pos = bullet_pos25.global_position
		elif -1.84 <= rot and rot < -1.73:
			player_anim_sprite.frame = 26
			rot = -1.84
			bullet_pos = bullet_pos26.global_position
		elif -1.73 <= rot and rot < -1.63:
			player_anim_sprite.frame = 27
			rot = -1.70
			bullet_pos = bullet_pos27.global_position
		elif -1.63 <= rot and rot < -1.48:
			player_anim_sprite.frame = 28
			rot = -1.58
			bullet_pos = bullet_pos28.global_position
		elif -1.48 <= rot and rot < -1.33:
			player_anim_sprite.frame = 29
			rot = -1.45
			bullet_pos = bullet_pos29.global_position
		elif -1.33 <= rot and rot < -1.18:
			player_anim_sprite.frame = 30
			rot = -1.33
			bullet_pos = bullet_pos30.global_position
		elif -1.18 <= rot and rot < -1.00:
			player_anim_sprite.frame = 31
			rot = -1.12
			bullet_pos = bullet_pos31.global_position
		elif -1.00 <= rot and rot < -.825:
			player_anim_sprite.frame = 32
			rot = -1.00
			bullet_pos = bullet_pos32.global_position
		elif -.825 <= rot and rot < -.688:
			player_anim_sprite.frame = 33
			rot = -.80
			bullet_pos = bullet_pos33.global_position
		elif -.688 <= rot and rot < -.55:
			player_anim_sprite.frame = 34
			rot = -.65
			bullet_pos = bullet_pos34.global_position
		elif -.55 <= rot and rot < -.46:
			player_anim_sprite.frame = 35
			rot = -.55
			bullet_pos = bullet_pos35.global_position
		elif -.46 <= rot and rot < -.32:
			player_anim_sprite.frame = 36
			rot = -.45
			bullet_pos = bullet_pos36.global_position
		elif -.32 <= rot and rot < -.08:
			player_anim_sprite.frame = 37
			rot = -.225
			bullet_pos = bullet_pos37.global_position
			

		else:
			player_anim_sprite.frame = 0
			rot = 0
			bullet_pos = bullet_pos0.global_position
		
		Global.playerhorse_rot = rot
		emit_signal("set_aim_dir")

func get_player_action():
	if leverAction:
		return
	if player_anim_sprite.animation == "default":
		if Input.is_action_just_pressed("player_shoot"):
	
			if Global.device == "PC" && get_global_mouse_position().y > Global.mouse_max_y:
				return
			if leverAction:
				return
			shoot_AR()

				
		if Input.is_action_just_pressed("player_evade"):
			if leverAction:
				return
			evade()
				
	if Input.is_action_just_released("player_evade"):
		if leverAction:
			return
		end_evade()
			

func evade():
	if !dodging:
		dodging = true
		$PlayerArea2D/PlayerCollisionShape2D.disabled = true
		player_anim_sprite.play("evade")

func end_evade():
	if dodging:
		dodging = false
		$PlayerArea2D/PlayerCollisionShape2D.disabled = false
		set_default_anim()

	
func get_horse_movement(delta):
	var stop_moving = false
	#fast_gallop = false
	if stop_moving == false:
		if Input.is_action_pressed("ui_left"):
			vel = Vector2(-200, 0)
		else: vel = Vector2(0, 0)
		if Input.is_action_pressed("ui_right"):
			vel = Vector2(200, 0)
		if Input.is_action_pressed("ui_up"):
			vel = Vector2(0, -140)
		if Input.is_action_pressed("ui_down"):
			vel = Vector2(0, 220)
			#fast_gallop = true
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
			vel = Vector2(-175, -175)
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_down"):
			vel = Vector2(-175, 175)
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_up"):
			vel = Vector2(175, -175)
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
			vel = Vector2(175, 175)


	move_and_collide(vel * delta)
	global_position.x = clamp(global_position.x, Global.player_lower_bounds.x, Global.player_upper_bounds.x)
	global_position.y = clamp(global_position.y, Global.player_lower_bounds.y, Global.player_upper_bounds.y)
	pos = global_position

	
	Global.playerhorse_pos = pos
	Global.playerhorse_vel = vel
	emit_signal("set_move_dir")

	
	"""
	update this, it's wrong
	"""
	if pos.x > 1175:
		pos.x = 1175
	if pos.x < 25:
		pos.x = 25
	if pos.y > 610:
		pos.y = 610
	if pos.y < 50:
		pos.y = 50


func _physics_process(delta):
	if Global.player_health > 0 && Global.playerhorse_health > 0:
		get_player_direction()
		get_player_action()
		get_horse_movement(delta)
		

func _damage(hitbox, damage, type, _pos):
	if type == "gunshot":
		var blood_impact = BloodImpact.instance()
		add_child(blood_impact)
		blood_impact.init(_pos, type+str("_player"))	#or pos?
		#blood_impact.scale = Vector2(2, 2)
		
		if hitbox == player_hitbox:
			Global.player_health -= (damage * 0.15)	#reduce damage impact to ease difficulty
		elif hitbox == horse_bullet_hitbox:
			Global.playerhorse_health -= (damage * 0.15) #reduce damage impact to ease difficulty
			if !$Sounds/Neigh.playing:
				$Sounds/Neigh.play()
	elif type == "kick":
		var kick_impact = KickImpact.instance()
		add_child(kick_impact)
		kick_impact.init(_pos)
		
		
		Global.playerhorse_health -= damage
		if !$Sounds/Neigh.playing:
			$Sounds/Neigh.play()
	
		
	
	if Global.player_health <= 0 || Global.playerhorse_health <= 0:
		emit_signal("game_over")
	#else:
	emit_signal("health_changed")
		


		
	

func _heal(healee, _health):
	if healee == "player":
		Global.player_health += _health
	elif healee == "horse":
		Global.playerhorse_health += _health
	
func _change_health(damage):
	pass

func shoot_AR():
	if leverAction || reloading:
		return
#	if AR_timer.get_time_left() == 0:
#		AR_timer.start()
	var gunshot_choice = Global.gunshots[randi()%3]

	var m = muzzle_flash1.instance()
	add_child(m)
	m.init(rot, bullet_pos)
	#gun_sounds.play(gunshot_choice)
	
	emit_signal("shoot", rot, bullet_pos, "Player")
	
	AR_ammo += 1
	emit_signal("ammo_changed")
	if AR_ammo / Global.player_mag_cap == 1:
		reloading = true
		reload_AR()
		AR_ammo = 0
	else:

#
		leverAction = true
		yield(get_tree().create_timer(0.2), "timeout")
		if weakref(self).get_ref():
			cycle_lever()

			
func cycle_lever():
	
	var current_frame = player_anim_sprite.frame
	var current_lever_dir
	
	leverAction = true

	player_anim_sprite.animation = "lever_action"
	
	
	
#	if current_frame in frames_aiming_front:
#		player_anim_sprite.frame = 0
#		current_lever_dir = $PlayerArea2D/LeverAction/Middle
#	elif current_frame in frames_aiming_left:
#		player_anim_sprite.frame = 1
#		current_lever_dir = $PlayerArea2D/LeverAction/Left
#	elif current_frame in frames_aiming_right:
#		player_anim_sprite.frame = 2
#		current_lever_dir = $PlayerArea2D/LeverAction/Right
		
	player_anim_sprite.frame = 0
	current_lever_dir = $PlayerArea2D/LeverAction/Middle
	var lever_anim = $PlayerArea2D/LeverAction/LeverActionAnimatedSprite
	var lever_sound = $Sounds/LeverAction
	lever_anim.global_position = current_lever_dir.global_position
	lever_anim.global_rotation = current_lever_dir.global_rotation
	lever_anim.frame = 0
	lever_anim.play("default")
	lever_sound.play()
			
		

func reload_AR():
	player_anim_sprite.play("reload")
	$Sounds/Reload.play()


	
func set_default_anim():
	emit_signal("ammo_changed")
	reloading = false
	dodging = false
	player_anim_sprite.stop()
	player_anim_sprite.animation = "default"

func _on_PlayerAnimatedSprite_animation_finished():
	if dodging && Input.is_action_pressed("player_evade"):
		return
	set_default_anim()


func _on_LeverAction_finished():
	
	leverAction = false
	set_default_anim()



func _on_PlayerAnimatedSprite_frame_changed():
	if player_anim_sprite.animation == "reload" && player_anim_sprite.frame == 3:
		var lever_anim = $PlayerArea2D/LeverAction/LeverActionAnimatedSprite
		lever_anim.play("reload")
	
