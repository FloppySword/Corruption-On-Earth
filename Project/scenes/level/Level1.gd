extends Node2D

signal game_over
signal game_won


var Enemy = preload("res://scenes/level/character/enemy/EnemyVehicle.tscn")
var GunshotWound = preload("res://scenes/gunshot_wound.tscn")
var HitPos = preload("res://scenes/hit_pos.tscn")
var Bullet = preload("res://scenes/level/item/Bullet.tscn")
var Treadmark = preload("res://scenes/level/character/Treadmark.tscn")
var Explosion = preload("res://scenes/level/character/Explosion.tscn")




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
onready var player_healthbar = $HUD/BottomBorder/HealthBarContainer/Player/PlayerHealth
onready var horse_healthbar = $HUD/BottomBorder/HealthBarContainer/Horse/HorseHealth

onready var upper_bounds = $Gameplay/UpperBounds.global_position
onready var lower_bounds = $Gameplay/LowerBounds.global_position
onready var player_upper_bounds = $Gameplay/UpperBounds/PlayerUpperBounds.global_position
onready var player_lower_bounds = $Gameplay/LowerBounds/PlayerLowerBounds.global_position

onready var joystickMovement = $HUD/BottomBorder/MobileButtons/MovementJoystick
onready var joystickAiming = $HUD/BottomBorder/MobileButtons/AimingJoystick

var bge1_pos 
var bge2_pos
var bge1_startpos = Vector2(599.1729, 2100)
var bge2_startpos = Vector2(599.1729, 2100)

var time_start = 0
var time_now = 0
var waves = global.waves
var wave = 1

export(bool) var DEBUG: = false



func _ready():
	#Toggle to debug mobile
	#global.device = "Mobile"
	
	$AnimationPlayer.play(global.device)
	
	randomize()
	time_start = OS.get_unix_time()
	player_horse.connect("shoot", self, "_spawn_bullet")
	player_horse.connect("hoof_step", self, "_spawn_treadmark")
	player_horse.connect("game_over", self, "_set_game_over")

	global.upper_bounds = upper_bounds
	global.lower_bounds = lower_bounds
	global.player_upper_bounds = player_upper_bounds
	global.player_lower_bounds = player_lower_bounds
	global.current_level = self
	
	global.enemy_spawns = enemy_spawns
	global.die_targets = die_targets

	joystickAiming.connect("joystick_shoot", self, "_mobile_shoot")


	get_tree().set_pause(false)
	show_player_health()
	
	if DEBUG:
		$DEBUG.visible = true
		$DEBUG.enemy_container = $Gameplay/enemy_container
		$DEBUG.cohesion_force = 0.00
		$DEBUG.align_force = 0.00
		$DEBUG.separation_force = 0.85
		$DEBUG.view_distance = 65.0
		$DEBUG.avoid_distance = 95.0
		$DEBUG.set_vars()
	else:
		$DEBUG.visible = false
	
#func _enemy_remote_fall(enemy, enemy_pos):
#	if enemy.get_parent() == effects_container:
#		return
#
#	var old_transform = enemy.get_global_transform()
#	var seat = enemy.get_parent()
#	seat.remove_child(enemy)
#	effects_container.add_child(enemy)
#	enemy.transform = effects_container.get_global_transform().inverse() * old_transform
##
#	func _reparent(new_parent, node, old_transform):
#    node.get_parent().remove_child(node)
#    new_parent.add_child(node)
#    node.transform = new_parent.get_global_transform.inverse() * old_transform
	
func _spawn_bullet(dir, pos, shooter):
	var b = Bullet.instance()
	bullet_container.add_child(b)
	b.start_at(dir, pos, shooter)
	
	
func _spawn_treadmark(pos, type):
	var t = Treadmark.instance()
	effects_container.add_child(t)
	t.init(pos, type)
	
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
	e.init(enemyLeft, enemyRight, midpoint)
	
func _mobile_shoot():
	$AnimationPlayer.play("MobileShoot")


func spawn_enemy1(pos, type):
	var e = Enemy.instance()
	enemy_container.add_child(e)
	e.connect("skid", self, "_spawn_treadmark")
	e.connect("rider_shoot", self, "_spawn_bullet")
	e.connect("explosion", self, "_spawn_explosion")
	#e1.connect("dead", self, "")
	e.init(pos, type)


func show_player_health():
	var player_health_level = global.player_health
	var color = "green"
	if player_health_level < 40:
		color = "red"
	elif player_health_level < 70:
		color = "yellow"
	var texture = load("res://data/images/gui/health_%s.png" % color)
	player_healthbar.set_progress_texture(texture)
	player_healthbar.set_value(player_health_level)
	
	var horse_health_level = global.playerhorse_health
	color = "green"
	if horse_health_level < 40:
		color = "red"
	elif horse_health_level < 70:
		color = "yellow"
	texture = load("res://data/images/gui/health_%s.png" % color)
	horse_healthbar.set_progress_texture(texture)
	horse_healthbar.set_value(horse_health_level)
	
	
#func show_hit(shoot_location, hit_location):
#	# enemy blood splatter when shot
#	var splatter = GunshotWound.instance()
#	effects_container.add_child(splatter)
#	splatter.set_pos(hit_location)
#	splatter.set_emitting(true)


#func enemy_lose_health(collision_point):
#	var hit_position = HitPos.instance()
#	add_child(hit_position)
#	hit_position.global_position = (collision_point)
#
func set_next_wave():
	if wave == waves.size():
		set_game_won()
		return
		
	var nextWave = waves[wave]
	wave += 1
	var enemy_spawns_list = enemy_spawns.get_children()
	for i in range(0, nextWave.size() - 1):#wave):
		var nextType = nextWave[i]
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rn = rng.randi_range(0, enemy_spawns_list.size() - 1)
		spawn_enemy1(enemy_spawns_list[rn].global_position, nextType)
		enemy_spawns_list.remove(rn)
			

func _process(delta):
#	

	#var rn = rng.randi_range(0, e1_spawns.get_child_count())
#	HUD.set_layer(1)
#	get_tree().set_pause(false)
#	show_player_health()
	
	if enemy_container.get_child_count() == 0:
		set_next_wave()

	if bge1.global_position.y < -2100 / 2:
		bge1_pos = bge1_startpos
	else:
		bge1_pos = bge1.global_position
	if bge2.global_position.y < -2100 / 2:
		bge2_pos = bge2_startpos
	else:
		bge2_pos = bge2.global_position
	
	bge1_pos += global.ground_vel * delta
	bge2_pos += global.ground_vel * delta
	bge1.global_position = (bge1_pos)
	bge2.global_position = (bge2_pos)
	
	for effect in effects_container.get_children():
		effect.global_position += global.ground_vel * delta
		if effect.global_position.y < lower_bounds.y:
			effect.queue_free()
	
	
	
	#if global.device == "Mobile":
#		# Movement using Input functions:
#		var move := Vector2.ZERO
#		move.x = Input.get_axis("ui_left", "ui_right")
#		move.y = Input.get_axis("ui_up", "ui_down")
#		position += move * speed * delta
		
		# Rotation:
		#if joystickAiming and joystickAiming.is_pressed():
			#global.joystick_rot = joystickAiming.get_output().angle() - (PI/2)
			#global.joystick_rot = 



	
func _set_game_over():
	emit_signal("game_over")
	queue_free()
	#get_tree().set_pause(true)
	
func set_game_won():
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	global.score = 20000 - (37 * elapsed)
	emit_signal("game_won")
	queue_free()


	
	
