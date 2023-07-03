extends Node2D

# Toggle this true to see debug panel display.
# Currently the debug panel simply shows enemy boid settings
# which can be changed in real-time. 
export(bool) var DEBUG: = false

# Shortcut variables for scene nodes.
onready var player_horse = $Gameplay/PlayerHorse
onready var bge1 = $Gameplay/bge1
onready var bge2 = $Gameplay/bge2
onready var enemy_spawns = $Gameplay/enemy_spawns
onready var die_targets = $Gameplay/die_targets
onready var enemy_container = $Gameplay/enemy_container
onready var bullet_container = $Gameplay/bullet_container
onready var effects_container = $Gameplay/effects_container
onready var spawn_timer = $Gameplay/spawn_timer
onready var whinny_sounds = $Gameplay/whinny_sounds
onready var HUD = $HUD
onready var player_healthbar = $HUD/BottomBorder/PlayerHealth/Bars/PlayerHealth
onready var horse_healthbar = $HUD/BottomBorder/PlayerHealth/Bars/HorseHealth
onready var upper_bounds = $Gameplay/UpperBounds.global_position
onready var lower_bounds = $Gameplay/LowerBounds.global_position
onready var player_upper_bounds = $Gameplay/UpperBounds/PlayerUpperBounds.global_position
onready var player_lower_bounds = $Gameplay/LowerBounds/PlayerLowerBounds.global_position
onready var joystickMovement = $HUD/BottomBorder/MobileButtons/MovementJoystick
onready var joystickAiming = $HUD/BottomBorder/MobileButtons/AimingJoystick

# Instance scene variables
var Enemy = preload("res://scenes/level/character/enemy/EnemyVehicle.tscn")
var Bullet = preload("res://scenes/level/item/Bullet.tscn")
var Treadmark = preload("res://scenes/level/character/effects/Treadmark.tscn")
var Explosion = preload("res://scenes/level/character/effects/Explosion.tscn")

var bge1_pos:Vector2
var bge2_pos:Vector2
var bge1_startpos = Vector2(599.1729, 2100)
var bge2_startpos = Vector2(599.1729, 2100)

# Track gameplay time. Used to determine final score if game is won.
var time_start:float = 0
var time_now:float = 0

# Extract waves dictionary from Global.gd
var waves:Dictionary = Global.waves
var wave:int = 1

signal game_over
signal game_won


func _ready():
	randomize()
	
	# Set the maximum y-distance that mouse clicks are detected.
	# Essentially disables clicking in the HUD space below the actual level screen.
	Global.mouse_max_y = $HUD/BottomBorder.rect_global_position.y
	
	# By now the autoload script DetectMobileOrDesktop.gd has done its work and
	# queue_freed, but not before setting the Global.device variable which is used
	# here to play one of two animations in AnimationPlayer, either PC or Mobile.
	$AnimationPlayer.play(Global.device)
	
	# Start the gameplay time count. 
	time_start = OS.get_unix_time()
	
	#Connect PlayerHorse.tscn's signals to functions in this scene.
	player_horse.connect("shoot", self, "_spawn_bullet")
	player_horse.connect("hoof_step", self, "_spawn_treadmark")
	player_horse.connect("game_over", self, "_set_game_over")
	player_horse.connect("health_changed", self, "_update_healthbars")
	player_horse.connect("ammo_changed", self, "_update_ammobar")
	
	# Ensure that player health and other variables are reset.
	Global._reset_level_vars()
	
	# Set global variables to specific values of this level scene
	Global.upper_bounds = upper_bounds
	Global.lower_bounds = lower_bounds
	Global.player_upper_bounds = player_upper_bounds
	Global.player_lower_bounds = player_lower_bounds
	Global.enemy_spawns = enemy_spawns
	Global.die_targets = die_targets
	Global.current_level = self
	
	# Connect aiming joystick's shoot signal to the _mobile_shoot function.
	joystickAiming.connect("joystick_shoot", self, "_mobile_shoot")
	
	# Ensure that health and ammo bars are reset before game begins.
	_update_healthbars()
	_update_ammobar()
	
	# Sets whether the DEBUG scene should be activated based on the user's
	# setting of the DEBUG export variable in this scene.
	$HUD/DEBUG.DEBUG = DEBUG
	if DEBUG:
		$HUD/DEBUG.visible = true
		$HUD/DEBUG.enemy_container = $Gameplay/enemy_container
		$HUD/DEBUG.set_vars()
	else:
		$HUD/DEBUG.visible = false

func _process(delta):
	if enemy_container.get_child_count() == 0:
		# If game just begun or no enemies remain alive, the wave is over. 
		# Start the next wave.
		set_next_wave()
	
	# Control movement of the background effects ("bge"), i.e. the ripples in the sand.
	if bge1.global_position.y < -2100 / 2:
		bge1_pos = bge1_startpos
	else:
		bge1_pos = bge1.global_position
	if bge2.global_position.y < -2100 / 2:
		bge2_pos = bge2_startpos
	else:
		bge2_pos = bge2.global_position
	bge1_pos += Global.ground_vel * delta
	bge2_pos += Global.ground_vel * delta
	bge1.global_position = (bge1_pos)
	bge2.global_position = (bge2_pos)
	
	for effect in effects_container.get_children():
		# Move effects up, and delete them if their y-value is too low.
		effect.global_position += Global.ground_vel * delta
		if effect.global_position.y < lower_bounds.y:
			effect.queue_free()

#SPAWN FUNCTIONS
func _spawn_bullet(dir, pos, shooter):
	var b = Bullet.instance()
	bullet_container.add_child(b)
	b.start_at(dir, pos, shooter)
	
func _spawn_treadmark(pos, type):
	var t = Treadmark.instance()
	effects_container.add_child(t)
	t._initiate(pos, type)
	
func _spawn_blood():
	pass
	
func _spawn_explosion(enemy1, enemy2):
	var enemyLeft
	var enemyRight
	if enemy1.global_position.x > enemy2.global_position.x:
		enemyLeft = enemy2
		enemyRight = enemy1
	else:
		enemyLeft = enemy1
		enemyRight = enemy2
		
	enemyLeft.vehicle_state = enemyLeft.vehicleStates.Explode
	enemyRight.vehicle_state = enemyLeft.vehicleStates.Explode
		
	var midpoint = Vector2((enemy1.global_position.x + enemy2.global_position.x) / 2, \
				(enemy1.global_position.y + enemy2.global_position.y) / 2)
	var e = Explosion.instance()
	effects_container.add_child(e)
	e._initiate(enemyLeft, enemyRight, midpoint)
	
func spawn_enemy1(pos, type):
	var e = Enemy.instance()
	enemy_container.add_child(e)
	e.connect("skid", self, "_spawn_treadmark")
	e.connect("rider_shoot", self, "_spawn_bullet")
	e.connect("explosion", self, "_spawn_explosion")
	#e1.connect("dead", self, "")
	e._initiate(pos, type)


func _mobile_shoot():
	# Flashes the aiming joystick crosshairs to indicate that a shot has been fired.
	$AnimationPlayer.play("MobileShoot")

func _update_healthbars():
	var player_health_level = Global.player_health
	var color = "green"
	if player_health_level < 40:
		color = "red"
	elif player_health_level < 70:
		color = "yellow"
	var texture = load("res://data/images/gui/health_%s.png" % color)
	player_healthbar.set_progress_texture(texture)
	player_healthbar.set_value(player_health_level)
	
	var horse_health_level = Global.playerhorse_health
	color = "green"
	if horse_health_level < 40:
		color = "red"
	elif horse_health_level < 70:
		color = "yellow"
	texture = load("res://data/images/gui/health_%s.png" % color)
	horse_healthbar.set_progress_texture(texture)
	horse_healthbar.set_value(horse_health_level)

func _update_ammobar():
	var current_ammo = Global.player_mag_cap - Global.player.AR_ammo
	var new_text = ""
	for i in range(0, current_ammo):
		new_text += "|"
	$HUD/BottomBorder/Ammo.text = new_text

func set_next_wave():
	if wave == waves.size() + 1:
		#If the wave array has been exhausted, you've won.
		set_game_won()
		return
	
	var nextWave = waves[wave]
	wave += 1
	var enemy_spawns_list = enemy_spawns.get_children()
	for i in range(0, nextWave.size()):
		var nextType = nextWave[i]
		
		# Use yield + timer to stagger the wave spawns, so 
		# that they don't all spawn at once.
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rn = rng.randf_range(0.3, 0.7)
		if i > 0:
			# But only do this after the first spawn because
			# otherwise the waves will cycle through instantly.
			yield(get_tree().create_timer(rn), "timeout")
		
		# Increase enemy speed as game progresses, to make things 
		# more difficult.
		if i == (nextWave.size() / 2) - 1:
			Global.enemy_speed_normal += 10
		elif i == (nextWave.size() / 2) + 3:
			Global.enemy_speed_normal += 15
		
		# Prevent a spawn pos from being reused, which might cause physics issues
		# if an enemy spawns atop another.
		rn = rng.randi_range(0, enemy_spawns_list.size() - 1)
		spawn_enemy1(enemy_spawns_list[rn].global_position, nextType)
		enemy_spawns_list.remove(rn)

func _set_game_over():
	# Stop briefly before emitting game_over signal and queuing free.
	yield(get_tree().create_timer(1.5), "timeout")
	emit_signal("game_over")
	queue_free()
	
func set_game_won():
	# Stop briefly before emitting game_over signal and queuing free.
	yield(get_tree().create_timer(1.5), "timeout")
	# Unlike game_over, however, we want to calculate the player's score. 
	# We do it here because it's in this scene that we tracked elapsed time.
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	Global.score = 20000 - (37 * elapsed)
	if Global.score <= 0:
		# If the player let the game run for so long that score was <= 0, 
		# set it to at least equal 1.
		Global.score = 1
	emit_signal("game_won")
	queue_free()

