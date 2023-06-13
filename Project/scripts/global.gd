extends Node

var device = "PC"

var booster_present = false

# game settings
var game_begun = false
var game_over = false
var game_won = false
var game_reset = false
var show_credits = false
var score = 0
var high_score = 0
var level = 0


var mute_sound = false
var mute_music = false


var upper_bounds = Vector2.ZERO
var lower_bounds = Vector2.ZERO


#player settings
var player_starting_health = 100
var player_health = player_starting_health

var playerhorse_starting_health = 100
var playerhorse_health = player_starting_health


var player_bleeding = false
var player_grunts = ["player_grunts1", "player_grunts2", "player_grunts3", "player_grunts4", "player_grunts5"]
var gunshots = ["gunshot_1", "gunshot_2", "gunshot_3"]
var gun_dmg_min = 50
var gun_dmg_max = 120

var AR_active = true
var pistol_active = false

#player_horse settings
var player
var playerhorse_pos = Vector2()
var playerhorse_vel = Vector2()
var player_pos = Vector2()

var joystick_rot = 0

var ground_vel = Vector2(0, -400)

func _enemy_remote_shoot(enemy):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	yield(get_tree().create_timer(rng.randf_range(0.1, 0.7)), "timeout")
	enemy._shoot()


#enemy settings
var mob_speeds = [150, 100, 75, 125, 150, 150]
var mob_moans = ["mob_pain1", "mob_pain2", "mob_pain3", "mob_pain4"]
#enemy1
var emptyhorse_vels = [Vector2(-75, -75), Vector2(75, -75), Vector2(0, -75), Vector2(100, -75),
					   Vector2(-100, -75)] #add more later
var enemy1_health = 100
var enemy1_swing = 0

#enemy2
var emptyhorse_vels2 = [Vector2(-150, 300), Vector2(150, 250), Vector2(0, 250), Vector2(200, 300),
					   Vector2(-200, 200)] #add more later
var enemy2_health = 80
var enemy2_lures = [Vector2(100, 550), Vector2(200, 600), Vector2(300, 575), Vector2(400, 600),
					Vector2(500, 550), Vector2(600, 575), Vector2(700, 500), Vector2(800, 600),
					Vector2(900, 550), Vector2(1000, 475), Vector2(1100, 475)]
					
					
#lancer
var lancer_health = 5
var deadlancer_vels = [Vector2(-20, -20), Vector2(20, -20), Vector2(0, -20), Vector2(-75, -20), 
						Vector2(75, -20)]

#boss settings
var boss_health = 1500
var boss_speed = 250
var arrow_dirs = [0.97, 0.92, 1.02]
var boss_has_bled = false
var ricochets = ["ricochet1", "ricochet2", "ricochet3"]

#tailarcher settings
var tailarcher_left = false


#groups


#collisions
func collide_with():
	pass
