extends Node

var device = "PC"
var farsi = false

var booster_present = false

# game settings
#var game_begun = false
#var game_over = false
#var game_won = false
#var game_reset = false
#var show_credits = false
var score = 0
var high_score = 0
#var level = 0


export(String, MULTILINE) var credit_text_en
export(String, MULTILINE) var credit_text_fa

export(String, MULTILINE) var share_score_en
export(String, MULTILINE) var share_score_fa


#When language button is toggled in main menu scene, switch all members of the "Language" group to
#the selected language's values. Index 0 = English, 1 = Farsi. 
var Language = {
				"LearnMoreButton":["Learn More","تاعالطا"],
				"SignPetitionButton":["     Sign Petition","تساوخداد"],
				"PlayButton":["Play","یزاب"],
				"OptionsButton":["Options","یدنبرکیپ"],
				"ExitButton":["Exit","جراخ"],
				"CreditsButton":["Credits","عاجرا"],
				"SettingsTitle":["Settings","یدنبرکیپ"],
				"MasterVol":["Master Volume","ادص نازیم"],
				"MusicVol":["Music Volume","یقیسوم"],
				"SFXVol":["SFX Volume","یتوص یاه‌هولج"],
				"CreditsTitle":["Credits","عاجرا"],
				"CreditsBody":[credit_text_en, credit_text_fa],
				"GameWonLabel":["GAME WON","یزوریپ"],
				"ScoreLabel":["Score: 00000","هرمن: 000000"],
				"ScoreCopied":["SCORE COPIED","دش یپک هرمن"], 
				"GameOverLabel":["GAME OVER","یدرم وت"],
				"PlayAgainButton":["Play Again","هرابود"],
				"ReturnToMenuButton":["Main Menu","ونم"]
				}
var LanguageBanner = ["res://data/images/gui/banner_en.png", "res://data/images/gui/banner_fa.png"]


var mute_sound = false
var mute_music = false


var upper_bounds = Vector2.ZERO
var lower_bounds = Vector2.ZERO
var player_upper_bounds = Vector2.ZERO
var player_lower_bounds = Vector2.ZERO
var screen_middle = Vector2(600, 275)


#player settings
var player_starting_health = 100
var player_health = player_starting_health

var mouse_max_y = 0

var playerhorse_starting_health = 100
var playerhorse_health = player_starting_health


var player_bleeding = false
#var player_grunts = ["player_grunts1", "player_grunts2", "player_grunts3", "player_grunts4", "player_grunts5"]
var gunshots = ["gunshot_1", "gunshot_2", "gunshot_3"]
var gun_dmg_min = 50
var gun_dmg_max = 120



#player_horse settings
var player
var playerhorse_pos = Vector2()
var playerhorse_vel = Vector2()
var playerhorse_rot = 0
var player_pos = Vector2()

var player_mag_cap = 15


var bullet_primary_damage = 100	
var bullet_adtl_damage = 30

var joystick_rot = 0

var ground_vel = Vector2(0, -400)

var current_level

var enemy_spawns
var die_targets

#Waves
#Key: 		u = solo unarmed,
#			a = armed,
#			du = duo unarmed
#			da = duo armed
var waves = {
				1:["a"],#["u"],#["u","u","u","u","u"
				2:["u","u"],
				3:["a"],
				4:["u","u","u"],
				5:["a","a"],
				6:["u","u","u","u","u"],
				7:["du"],
				8:["a","a","a","a"],
				9:["du","du","du"],
				10:["du","a","a","a"],
				11:["da","da","da","da"]
			}

#Enemy boid variables
var target_force = 0.04
var cohesion_force = 0.00
var align_force = 0.03
var separation_force = 0.04
var view_distance = 100
var avoid_distance = 110
#var target_force = 0.04
#var cohesion_force = 0.00
#var align_force = 0.00
#var separation_force = 0.3
#var view_distance = 70
#var avoid_distance = 165


func _enemy_remote_shoot(enemy):
	if weakref(enemy).get_ref():
		#we do this here in the global script because calling the yield timer
		#should be done by a scene that can't disappear before
		#the time is up. 
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		yield(get_tree().create_timer(rng.randf_range(0.1, 0.7)), "timeout")
		if weakref(enemy).get_ref():
			enemy._shoot()
	
func _reset_level_vars():
	player_health = player_starting_health
	playerhorse_health = player_starting_health
	player_bleeding = false
