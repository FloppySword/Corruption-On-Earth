extends Node2D



#as a level, this will need its own init function that the new node I make can call after
#instancing it
#var boss_horse = preload("res://scenes/boss_horse.tscn")
var Enemy = preload("res://scenes/level/character/enemy/EnemyVehicle.tscn")
#var enemy2 = preload("res://scenes/enemy_horse2.tscn")
var gunshot_wound = preload("res://scenes/gunshot_wound.tscn")
var hit_pos = preload("res://scenes/hit_pos.tscn")
#var bullet_trail = preload("res://scenes/bullet_trail.tscn")
#var booster = preload("res://scenes/booster.tscn")

var Bullet = preload("res://scenes/level/item/Bullet.tscn")
var Treadmark = preload("res://scenes/level/character/Treadmark.tscn")


onready var player_horse = get_node("PlayerHorse")
onready var HUD = get_node("HUD")
onready var bge1 = get_node("bge1")
onready var bge2 = get_node("bge2")
onready var e1_spawns = get_node("e1_spawns")
onready var e2_spawns = get_node("e2_spawns")
onready var enemy_container = get_node("enemy_container")
onready var bullet_container = get_node("bullet_container")
onready var effects_container = get_node("effects_container")
onready var spawn_timer = get_node("spawn_timer")
onready var whinny_sounds = get_node("whinny_sounds")

onready var upper_bounds = $UpperBounds.global_position
onready var lower_bounds = $LowerBounds.global_position

var bge1_pos 
var bge2_pos
var bge_vel
var bge1_startpos = Vector2(599.1729, 2100)
var bge2_startpos = Vector2(599.1729, 2100)

var time_start = 0
var time_now = 0
var wave = 0


func _ready():
	player_horse.connect("hit", self, "show_hit")
	player_horse.connect("wound_enemy", self, "enemy_lose_health")
	randomize()
	time_start = OS.get_unix_time()
	player_horse.connect("shoot", self, "_spawn_bullet")
	player_horse.connect("hoof_step", self, "_spawn_treadmark")
	#global.game_won = falses
#	set_process(true)
#	set_process_input(true)

	global.upper_bounds = upper_bounds
	global.lower_bounds = lower_bounds


	#HUD.set_layer(-1)
	HUD.set_layer(1)

	get_tree().set_pause(false)
	show_player_health()
	
func _spawn_bullet(dir, pos):
	var b = Bullet.instance()
	bullet_container.add_child(b)
	b.start_at(dir, pos)
	
func _spawn_treadmark(pos, type):
	var t = Treadmark.instance()
	effects_container.add_child(t)
	t.init(pos, type)
	#t.global_position = pos


func spawn_enemy1(pos):
	var e = Enemy.instance()
	enemy_container.add_child(e)
	e.connect("skid", self, "_spawn_treadmark")
	#e1.connect("dead", self, "")
	e.init(pos, "MotorcycleDuo")
#
#func spawn_enemy2(pos):
#	var e2 = enemy2.instance()
#	enemyhorse_container.add_child(e2)
#	#e2.connect("dead_archer", self, "spawn_dead_archer")
#	e2.init(pos)
##func spawn_dead_archer(pos):
##	var e2_d = dead_archer.instance()
##	add_child(e2_d)
##	e2_d.set_pos(pos)
	
	
	
#func spawn_boss(pos):
#	var b1 = boss_horse.instance()
#	enemy_container.add_child(b1)
#	b1.init(pos)

func show_player_health():
	var health_level = global.player_health
	#print(health_level)
	var color = "green"
	if health_level < 40:
		color = "red"
	elif health_level < 70:
		color = "yellow"
	var texture = load("res://data/images/gui/health_%s.png" % color)
	HUD.get_node("ColorRect/player_health").set_progress_texture(texture)
	HUD.get_node("ColorRect/player_health").set_value(health_level)
	
	
	
	
	
func show_hit(shoot_location, hit_location):
	# enemy blood splatter when shot
	var splatter = gunshot_wound.instance()
	effects_container.add_child(splatter)
	splatter.set_pos(hit_location)
	splatter.set_emitting(true)
	#bullet trail
	#var trail = bullet_trail.instance()
	#add_child(trail)
#	trail.set_pos(shoot_location)
#	var trail_length = hit_location - shoot_location
#	trail.set_region_rect(Rect2(0, 0, trail_length.length(), 2))
#	trail.set_rot(-trail_length.angle_to(Vector2(1, 0)))
	
	


func enemy_lose_health(collision_point):
	var hit_position = hit_pos.instance()
	add_child(hit_position)
	hit_position.global_position = (collision_point)
	
	




func _process(delta):
#	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	#var rn = rng.randi_range(0, e1_spawns.get_child_count())
#	HUD.set_layer(1)
#	get_tree().set_pause(false)
#	show_player_health()
	
	if enemy_container.get_child_count() == 0:
		wave += 1
		var enemy_spawns = e1_spawns.get_children()
		for i in range(0, 1):#5):#wave):
			var rn = rng.randi_range(0, enemy_spawns.size() - 1)
			spawn_enemy1(enemy_spawns[rn].global_position)
			enemy_spawns.remove(rn)
			
	if bge1.global_position.y < -2100 / 2:
		bge1_pos = bge1_startpos
	else:
		bge1_pos = bge1.global_position
	if bge2.global_position.y < -2100 / 2:
		bge2_pos = bge2_startpos
	else:
		bge2_pos = bge2.global_position
	bge_vel = Vector2(0, -400)
	bge1_pos += bge_vel * delta
	bge2_pos += bge_vel * delta
	bge1.global_position = (bge1_pos)
	bge2.global_position = (bge2_pos)
	
	for effect in effects_container.get_children():
		effect.global_position += bge_vel * delta
		if effect.global_position.y < lower_bounds.y:
			effect.queue_free()
	
	if global.player_health <= 0:
		set_game_over()
		
	if global.boss_health <= 0:
		if global.boss_has_bled == true:
			global.boss_has_bled = false
			global.boss_health = 140
			wave += 1
			#global.game_won = true
			#HUD.set_layer(-1)
			#get_tree().set_pause(true)
	if wave >= 7:
		set_game_won()



#	if global.booster_present == false:
#		spawn_booster()
#	if randf() < 0.001:
#		if whinny_sounds.is_active() == false:
#			whinny_sounds.play("horse_whinny")
	
	
func set_game_over():
	global.game_over = true
	HUD.set_layer(-1)
	get_tree().set_pause(true)
	
func set_game_won():
	global.game_won = true
	HUD.set_layer(-1)
	get_tree().set_pause(true)
	time_now = OS.get_unix_time()
	var elapsed = time_now - time_start
	global.score = 20000 - 37 * elapsed

	
	
