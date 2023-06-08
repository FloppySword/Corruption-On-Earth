extends Node

#as a level, this will need its own init function that the new node I make can call after
#instancing it
var boss_horse = preload("res://scenes/boss_horse.tscn")
var enemy1 = preload("res://scenes/enemy_horse1.tscn")
var enemy2 = preload("res://scenes/enemy_horse2.tscn")
var gunshot_wound = preload("res://scenes/gunshot_wound.tscn")
var hit_pos = preload("res://scenes/hit_pos.tscn")
var bullet_trail = preload("res://scenes/bullet_trail.tscn")
var booster = preload("res://scenes/booster.tscn")


onready var player_horse = get_node("player_horse")
onready var HUD = get_node("HUD")
onready var bge1 = get_node("bge1")
onready var bge2 = get_node("bge2")
onready var e1_spawns = get_node("e1_spawns")
onready var e2_spawns = get_node("e2_spawns")
onready var enemyhorse_container = get_node("enemyhorse_container")
onready var splatter_container = get_node("splatter_container")
onready var spawn_timer = get_node("spawn_timer")
onready var whinny_sounds = get_node("whinny_sounds")

var bge1_pos 
var bge2_pos
var bge_vel
var bge1_startpos = Vector2(599.1729, 2100)
var bge2_startpos = Vector2(599.1729, 2100)

var time_start = 0
var time_now = 0
var wave = 1


func _ready():
	player_horse.player.connect("hit", self, "show_hit")
	player_horse.player.connect("wound_enemy", self, "enemy_lose_health")
	randomize()
	time_start = OS.get_unix_time()
	global.game_won = false
	set_process(true)
	set_process_input(true)
	HUD.set_layer(-1)
#	if global.game_begun == false:
#		get_tree().set_pause(true)
#	
#	if global.game_reset == true:
#		get_tree().set_pause(false)
	
	#get_tree().set_pause(false)
	
	
	
	
	
			

func spawn_booster():
	if randf() < 0.01:
		global.booster_present = true
		var booster1 = booster.instance()
		add_child(booster1)
		booster1.init(rand_range(10, 1190))



func spawn_enemy1(pos):
	var e1 = enemy1.instance()
	enemyhorse_container.add_child(e1)
	e1.init(pos)
	
func spawn_enemy2(pos):
	var e2 = enemy2.instance()
	enemyhorse_container.add_child(e2)
	#e2.connect("dead_archer", self, "spawn_dead_archer")
	e2.init(pos)
#func spawn_dead_archer(pos):
#	var e2_d = dead_archer.instance()
#	add_child(e2_d)
#	e2_d.set_pos(pos)
	
	
	
func spawn_boss(pos):
	var b1 = boss_horse.instance()
	enemyhorse_container.add_child(b1)
	b1.init(pos)

func show_player_health():
	var health_level = global.player_health
	#print(health_level)
	var color = "green"
	if health_level < 40:
		color = "red"
	elif health_level < 70:
		color = "yellow"
	var texture = load("res://data/images/gui/health_%s.png" % color)
	HUD.get_node("player_health").set_progress_texture(texture)
	HUD.get_node("player_health").set_value(health_level)
	
	
	
	
	
func show_hit(shoot_location, hit_location):
	# enemy blood splatter when shot
	var splatter = gunshot_wound.instance()
	splatter_container.add_child(splatter)
	splatter.set_pos(hit_location)
	splatter.set_emitting(true)
	#bullet trail
	var trail = bullet_trail.instance()
	add_child(trail)
	trail.set_pos(shoot_location)
	var trail_length = hit_location - shoot_location
	trail.set_region_rect(Rect2(0, 0, trail_length.length(), 2))
	trail.set_rot(-trail_length.angle_to(Vector2(1, 0)))
	
	


func enemy_lose_health(collision_point):
	var hit_position = hit_pos.instance()
	add_child(hit_position)
	hit_position.set_pos(collision_point)
	
	




func _process(delta):
	
	#if global.game_begun == true:
		
		#horse_sounds()
	HUD.set_layer(1)
	get_tree().set_pause(false)
	show_player_health()
	if wave == 1:
		if enemyhorse_container.get_child_count() == 0:
			wave += 1
			for i in range(1):
				spawn_enemy2(e2_spawns.get_child(i).get_pos())
	if wave == 2:
		if enemyhorse_container.get_child_count() == 0:
			wave += 1
			for i in range(1):
				spawn_enemy1(e1_spawns.get_child(i).get_pos())
			#for i in range(2):
			#	spawn_enemy2(e2_spawns.get_child(i).get_pos())
	if wave == 3:
		if enemyhorse_container.get_child_count() <= 1:
			wave += 1
			for i in range(1):
				spawn_enemy2(e2_spawns.get_child(i).get_pos())
			for i in range(1):
				spawn_enemy1(e1_spawns.get_child(i).get_pos())
	if wave == 4:
		if enemyhorse_container.get_child_count() <= 3:
			wave += 1
			for i in range(1):
				spawn_enemy1(e1_spawns.get_child(i).get_pos())
				spawn_enemy2(e2_spawns.get_child(i).get_pos())
	if wave == 5:
		wave += 1
		if enemyhorse_container.get_child_count() <= 0:
			for i in range(1):
				spawn_enemy2(e2_spawns.get_child(i).get_pos())
	if wave == 6:
		if enemyhorse_container.get_child_count() == 0:
			spawn_boss(e1_spawns.get_child(3).get_pos())
		
	if bge1.get_pos().y < -2100 / 2:
		bge1_pos = bge1_startpos
	else:
		bge1_pos = bge1.get_pos()
	if bge2.get_pos().y < -2100 / 2:
		bge2_pos = bge2_startpos
	else:
		bge2_pos = bge2.get_pos()
	bge_vel = Vector2(0, -300)
	bge1_pos += bge_vel * delta
	bge2_pos += bge_vel * delta
	bge1.set_pos(bge1_pos)
	bge2.set_pos(bge2_pos)
	
	if global.player_health <= 0:
		global.game_over = true
		HUD.set_layer(-1)
		get_tree().set_pause(true)
	if global.boss_health <= 0:
		if global.boss_has_bled == true:
			global.boss_has_bled = false
			global.boss_health = 140
			wave += 1
			#global.game_won = true
			#HUD.set_layer(-1)
			#get_tree().set_pause(true)
	if wave >= 7:
		global.game_won = true
		HUD.set_layer(-1)
		get_tree().set_pause(true)
		
		
	if get_tree().is_paused() == false:	
		time_now = OS.get_unix_time()
		var elapsed = time_now - time_start
		global.score = 20000 - 37 * elapsed


	if global.booster_present == false:
		spawn_booster()
#	if randf() < 0.001:
#		if whinny_sounds.is_active() == false:
#			whinny_sounds.play("horse_whinny")
	

	
	
		
	

