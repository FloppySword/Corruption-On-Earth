extends Node

#as a level, this will need its own init function that the new node I make can call after
#instancing it
var boss_horse = preload("res://scenes/boss_horse.tscn")
var enemy1 = preload("res://scenes/enemy_horse1.tscn")
var enemy2 = preload("res://scenes/enemy_horse2.tscn")

onready var HUD = get_node("HUD")
onready var bge1 = get_node("bge1")
onready var bge2 = get_node("bge2")
onready var e1_spawns = get_node("e1_spawns")
onready var e2_spawns = get_node("e2_spawns")
onready var mob_container = get_node("mob_container")
onready var spawn_timer = get_node("spawn_timer")
onready var gallop_sounds = get_node("gallop_sounds")
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
	randomize()
	time_start = OS.get_unix_time()
	global.game_won = false
	set_process(true)
	set_process_input(true)
	HUD.set_layer(-1)
	
	
	
func spawn_enemy1(pos):
	var e1 = enemy1.instance()
	mob_container.add_child(e1)
	e1.init(pos)
	
func spawn_enemy2(pos):
	var e2 = enemy2.instance()
	mob_container.add_child(e2)
	#e2.connect("dead_archer", self, "spawn_dead_archer")
	e2.init(pos)
#func spawn_dead_archer(pos):
#	var e2_d = dead_archer.instance()
#	add_child(e2_d)
#	e2_d.set_pos(pos)
	
	
	
func spawn_boss(pos):
	var b1 = boss_horse.instance()
	mob_container.add_child(b1)
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

func _process(delta):

	
	horse_sounds()
	HUD.set_layer(1)
	get_tree().set_pause(false)
	show_player_health()
	if wave == 1:
		if mob_container.get_child_count() == 0:
			for i in range(3):
				spawn_enemy1(e1_spawns.get_child(i).get_pos())
		
	
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
	if wave >= 2:
		global.game_won = true
		HUD.set_layer(-1)
		get_tree().set_pause(true)
		
		
	if get_tree().is_paused() == false:	
		time_now = OS.get_unix_time()
		var elapsed = time_now - time_start
		global.score = 20000 - 37 * elapsed

		
			

			
			
	
func horse_sounds():
	if gallop_sounds.is_active() == false:
		gallop_sounds.play("horse_gallop5")
		
	if randf() < 0.001:
		if whinny_sounds.is_active() == false:
			whinny_sounds.play("horse_whinny")
	

	
	
		
	

