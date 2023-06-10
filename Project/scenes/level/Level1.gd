extends Node2D

signal game_over
signal game_won


var Enemy = preload("res://scenes/level/character/enemy/EnemyVehicle.tscn")
var GunshotWound = preload("res://scenes/gunshot_wound.tscn")
var HitPos = preload("res://scenes/hit_pos.tscn")
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
#	player_horse.connect("hit", self, "show_hit")
#	player_horse.connect("wound_enemy", self, "enemy_lose_health")
	randomize()
	time_start = OS.get_unix_time()
	player_horse.connect("shoot", self, "_spawn_bullet")
	player_horse.connect("hoof_step", self, "_spawn_treadmark")
	player_horse.connect("game_over", self, "_set_game_over")
	
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
	
func _spawn_blood():
	pass


func spawn_enemy1(pos):
	var e = Enemy.instance()
	enemy_container.add_child(e)
	e.connect("skid", self, "_spawn_treadmark")
	#e1.connect("dead", self, "")
	e.init(pos, "MotorcycleDuo")


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
	

func _process(delta):
#	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	#var rn = rng.randi_range(0, e1_spawns.get_child_count())
#	HUD.set_layer(1)
#	get_tree().set_pause(false)
#	show_player_health()
	
	if enemy_container.get_child_count() == 0:
		if wave == 4:
			set_game_won()
			return
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


	
	
