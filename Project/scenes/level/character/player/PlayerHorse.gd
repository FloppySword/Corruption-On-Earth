extends KinematicBody2D

# Shortcut variables for scene nodes.
onready var player_hitbox = $PlayerArea2D
onready var horse_bullet_hitbox = $HorseBulletDamageArea2D
onready var horse_kick_hitbox = $HorseKickDamageArea2D
onready var shoot_pos_left = $ChasePositions/LeftShooting
onready var shoot_pos_right = $ChasePositions/RightShooting
onready var kick_pos_left = $ChasePositions/LeftKicking
onready var kick_pos_right = $ChasePositions/RightKicking
onready var player_anim_sprite = $PlayerArea2D/PlayerAnimatedSprite
onready var bullet_pos0 = $PlayerArea2D/MuzzlePositions/pos0
onready var bullet_pos1 = $PlayerArea2D/MuzzlePositions/pos1
onready var bullet_pos2 = $PlayerArea2D/MuzzlePositions/pos2
onready var bullet_pos3 = $PlayerArea2D/MuzzlePositions/pos3
onready var bullet_pos4 = $PlayerArea2D/MuzzlePositions/pos4
onready var bullet_pos5 = $PlayerArea2D/MuzzlePositions/pos5
onready var bullet_pos6 = $PlayerArea2D/MuzzlePositions/pos6
onready var bullet_pos7 = $PlayerArea2D/MuzzlePositions/pos7
onready var bullet_pos8 = $PlayerArea2D/MuzzlePositions/pos8
onready var bullet_pos9 = $PlayerArea2D/MuzzlePositions/pos9
onready var bullet_pos10 = $PlayerArea2D/MuzzlePositions/pos10
onready var bullet_pos11 = $PlayerArea2D/MuzzlePositions/pos11
onready var bullet_pos12 = $PlayerArea2D/MuzzlePositions/pos12
onready var bullet_pos13 = $PlayerArea2D/MuzzlePositions/pos13
onready var bullet_pos14 = $PlayerArea2D/MuzzlePositions/pos14
onready var bullet_pos15 = $PlayerArea2D/MuzzlePositions/pos15
onready var bullet_pos16 = $PlayerArea2D/MuzzlePositions/pos16
onready var bullet_pos17 = $PlayerArea2D/MuzzlePositions/pos17
onready var bullet_pos18 = $PlayerArea2D/MuzzlePositions/pos18
onready var bullet_pos19 = $PlayerArea2D/MuzzlePositions/pos19
onready var bullet_pos20 = $PlayerArea2D/MuzzlePositions/pos20
onready var bullet_pos21 = $PlayerArea2D/MuzzlePositions/pos21
onready var bullet_pos22 = $PlayerArea2D/MuzzlePositions/pos22
onready var bullet_pos23 = $PlayerArea2D/MuzzlePositions/pos23
onready var bullet_pos24 = $PlayerArea2D/MuzzlePositions/pos24
onready var bullet_pos25 = $PlayerArea2D/MuzzlePositions/pos25
onready var bullet_pos26 = $PlayerArea2D/MuzzlePositions/pos26
onready var bullet_pos27 = $PlayerArea2D/MuzzlePositions/pos27
onready var bullet_pos28 = $PlayerArea2D/MuzzlePositions/pos28
onready var bullet_pos29 = $PlayerArea2D/MuzzlePositions/pos29
onready var bullet_pos30 = $PlayerArea2D/MuzzlePositions/pos30
onready var bullet_pos31 = $PlayerArea2D/MuzzlePositions/pos31
onready var bullet_pos32 = $PlayerArea2D/MuzzlePositions/pos32
onready var bullet_pos33 = $PlayerArea2D/MuzzlePositions/pos33
onready var bullet_pos34 = $PlayerArea2D/MuzzlePositions/pos34
onready var bullet_pos35 = $PlayerArea2D/MuzzlePositions/pos35
onready var bullet_pos36 = $PlayerArea2D/MuzzlePositions/pos36
onready var bullet_pos37 = $PlayerArea2D/MuzzlePositions/pos37
onready var bullet_pos38 = $PlayerArea2D/MuzzlePositions/pos38

# Instance scene variables
var MuzzleFlash = preload("res://scenes/level/character/effects/MuzzleFlash.tscn")
var KickImpact = preload("res://scenes/level/character/effects/KickImpact.tscn")
var BloodImpact = preload("res://scenes/level/character/effects/BloodEffect.tscn")

# Movement variables
var pos:Vector2 = Vector2.ZERO
var vel:Vector2 = Vector2()

# Shooting variables
var mouse_pos = Vector2()
var rot:float = 0
var AR_ammo:int = 0
var bullet_pos:Vector2 = Vector2.ZERO

# State boolean variables
var reloading:bool = false
var dodging:bool = false
var leverAction:bool = false

# Manually went thru player animation frames to determine whether each is a 
# front, right, or left aiming frame. Grouped accordingly. 
# (Note 07/02/2023: May no longer be relevant, possibly delete.)
var frames_aiming_front:Array = [0, 1, 2, 3, 4, 5, 34, 35, 36, 37, 38]
var frames_aiming_left:Array = [6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
var frames_aiming_right:Array = [22,23,24,25,26,27,28,29,30,31,32,33]


signal shoot
signal hoof_step
signal game_over
signal health_changed
signal ammo_changed


func _ready():
	randomize()

	Global.player = self	
	pos = global_position
	player_anim_sprite.animation = "default"
	$AnimationPlayer.play("HorseGallop")
	$PlayerArea2D/PlayerCollisionShape2D.disabled = false

func _input(event):
	
	if event is InputEventMouseMotion && Global.device == "PC":
		# If the mouse was moved and the device is a computer
		mouse_pos = get_global_mouse_position()
		if mouse_pos.y > Global.mouse_max_y:
			# We don't want to calculate new rotation if the cursor
			# is not within the gameplay window.
			return
		# Set "rot" variable to be in direction of mouse position.
		# This rotation variable is used later to determine which frame
		# to display in the player animation sprite.
		var target_dist = mouse_pos - global_position
		rot = -target_dist.angle_to(Vector2(0, 1))
		

func _physics_process(delta):
	if Global.player_health > 0 && Global.playerhorse_health > 0:
		# If the player and horse are alive, call these functions.
		get_player_direction()
		get_player_action()
		get_horse_movement(delta)
		
func get_player_direction():
	# This function sets the appropriate frame of the PlayerAnimatedSprite node.
	# A bullet pos spawn pos is also set, so that if a shooting event occurs
	# the bullet will fire from the correct position. 

	# If the default animation is playing, i.e. the player isn't actively
	# dodging, reloading, or pulling the lever action.
	if player_anim_sprite.animation == "default":
		if Global.device == "Mobile":
			# If mobile, set initial rot based on aiming joystick's rotation. 
			# This is essentially the alternate of the mouse calculation in the
			# above _input function, which is for PC users.
			rot = Global.joystick_rot
			
		# The pre-calculated "rot" rotation variable is rounded to one of 38 possible 
		# values, each with a corresponding frame for the PlayerAnimationSprite node
		# as well as a bullet_pos which will be used to set the bullet's initial spawn pos.
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


func get_player_action():
	# This function determines whether the player's state should change
	# based on inputs such as shooting or dodging, or reloading. 
	
	if leverAction:
		# If the lever action is active between shots
		return
		
	# If the default animation is playing, i.e. the player isn't actively
	# dodging, reloading, or pulling the lever action.
	if player_anim_sprite.animation == "default":
		if Input.is_action_just_pressed("player_shoot"):
			if Global.device == "PC" && get_global_mouse_position().y > Global.mouse_max_y:
				# If on computer and clicked outside gameplay window
				return
			if leverAction:
				# If the lever action is active between shots
				return
			shoot_AR()

		if Input.is_action_just_pressed("player_evade"):
			if leverAction:
				# If the lever action is active between shots
				return
			evade()
				
	if Input.is_action_just_released("player_evade"):
		if leverAction:
			# If the lever action is active between shots
			return
		end_evade()
		

func get_horse_movement(delta):
	# This function sets the horse's velocity based on player input. 
	# It also calls the KinematicBody2D's move_and_collide function which
	# requires the delta parameter. 
	
	var stop_moving = false
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
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
			vel = Vector2(-175, -175)
		if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_down"):
			vel = Vector2(-175, 175)
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_up"):
			vel = Vector2(175, -175)
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
			vel = Vector2(175, 175)

	move_and_collide(vel * delta)
	
	# Prevent the player from travelling outside the bounds of the gameplay window. 
	global_position.x = clamp(global_position.x, Global.player_lower_bounds.x, Global.player_upper_bounds.x)
	global_position.y = clamp(global_position.y, Global.player_lower_bounds.y, Global.player_upper_bounds.y)
	
	# Update the pos variable witht he current global position. 
	pos = global_position

	# Update global variables that are referenced elsewhere in the project. 
	Global.playerhorse_pos = pos
	Global.playerhorse_vel = vel



func shoot_AR():
	if leverAction || reloading:
		# Shooting disabled if currently pulling lever or reloading
		return
	
	# Spawn a muzzle flash locally
	var m = MuzzleFlash.instance()
	add_child(m)
	m._initiate(rot, bullet_pos)
	
	# Emit signal to spawn bullet remotely (in Level1.tscn)
	emit_signal("shoot", rot, bullet_pos, "Player")
	
	# Add to the AR_ammo counter variable. 
	# Once this variable's value equals the magazine cap,
	# the player is forced to reload. 
	AR_ammo += 1
	# Send ammo change signal upward so that the HUD ammo display can be updated. 
	emit_signal("ammo_changed")
	
	if AR_ammo / Global.player_mag_cap == 1:
		# Time to reload
		reloading = true
		reload_AR()
		# Reset the counter variable
		AR_ammo = 0
	else:
		# Slide lever
		leverAction = true
		# But wait a moment after firing
		yield(get_tree().create_timer(0.2), "timeout")
		if weakref(self).get_ref():
			# This should always be true, but we use weakref
			# on off chance that the player scene was removed
			# before timeout. 
			cycle_lever()

func cycle_lever():

	
	# Set boolean to true to prevent other inputs from interrupting the lever
	# animation
	leverAction = true
	

	player_anim_sprite.animation = "lever_action"
	
	# No longer using the left/right lever dirs, so hard-coding to middle. 
	var lever_anim = $PlayerArea2D/LeverAction/LeverActionAnimatedSprite
	lever_anim.global_position = $PlayerArea2D/LeverAction/Middle.global_position
	lever_anim.global_rotation = $PlayerArea2D/LeverAction/Middle.global_rotation
	lever_anim.frame = 0
	lever_anim.play("default")
	
	var lever_sound = $Sounds/LeverAction
	lever_sound.play()

func reload_AR():
	player_anim_sprite.play("reload")
	$Sounds/Reload.play()

func evade():
	# If already dodging, do nothing
	if !dodging:
		dodging = true
		# Disable player's hitbox collision shape so it can't be damaged
		$PlayerArea2D/PlayerCollisionShape2D.disabled = true
		player_anim_sprite.play("evade")

func end_evade():
	# If not dodging, do nothing
	if dodging:
		dodging = false
		# Enable player's hitbox collision shape so it can be damaged
		$PlayerArea2D/PlayerCollisionShape2D.disabled = false
		set_default_anim()
	
func set_default_anim():
	# A function designed to essentially reset things between animations
	# and play the default animation (the one that shows the player's aiming)
	emit_signal("ammo_changed")
	reloading = false
	dodging = false
	player_anim_sprite.stop()
	player_anim_sprite.animation = "default"

func hoof_step(right_hoof:bool):
	# Called from animation player (gallop animation). 
	# Sends a signal to the Level scene to spawn a hoof
	# step effect on the ground.
	var hoof_pos = global_position
	
	# Add a small amount of padding to the hoof spawn position
	if right_hoof:
		hoof_pos += Vector2(5, 10)
	else:
		hoof_pos += Vector2(-5, 10)

	emit_signal("hoof_step", hoof_pos, "hoof")
	
func _damage(hitbox, damage, type, _pos):
	# This function is called remotely and takes the same parameters as the identically
	# named _damage function in Enemy.gd. 
	if type == "gunshot":
		# If shot, blood must spawn at impact position.
		var blood_impact = BloodImpact.instance()
		add_child(blood_impact)
		blood_impact._initiate(_pos, type+str("_player"))
		
		# Either the player or the horse gets the damage
		if hitbox == player_hitbox:
			Global.player_health -= (damage * 0.15)	#reduce damage impact to ease difficulty
		elif hitbox == horse_bullet_hitbox:
			Global.playerhorse_health -= (damage * 0.15) #reduce damage impact to ease difficulty
			if !$Sounds/Neigh.playing:
				$Sounds/Neigh.play()
	elif type == "kick":
		# If the horse got kicked
		var kick_impact = KickImpact.instance()
		add_child(kick_impact)
		kick_impact._initiate(_pos)
		Global.playerhorse_health -= damage
		if !$Sounds/Neigh.playing:
			$Sounds/Neigh.play()
	
	# After damage has been applied, check whether the player or horse
	# have 0 health in which case the game is over. 
	if Global.player_health <= 0 || Global.playerhorse_health <= 0:
		emit_signal("game_over")
	
	# Signal to update the health bars in the HUD.
	emit_signal("health_changed")

func _on_PlayerAnimatedSprite_animation_finished():
	if dodging && Input.is_action_pressed("player_evade"):
		# If the player is still holding down the evade key, keep dodging
		return
	# Otherwise, reset animation state. 
	set_default_anim()

func _on_LeverAction_finished():
	# Reset animation state
	leverAction = false
	set_default_anim()

func _on_PlayerAnimatedSprite_frame_changed():
	# This signal is really only connected so that we can time exactly when to play
	# the lever movement animation (the white streak which indicates the motion
	# of sliding the lever.
	if player_anim_sprite.animation == "reload" && player_anim_sprite.frame == 3:
		var lever_anim = $PlayerArea2D/LeverAction/LeverActionAnimatedSprite
		lever_anim.play("reload")
		
		
