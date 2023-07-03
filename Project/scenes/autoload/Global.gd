extends Node



"""============================================================================
System/Settings
============================================================================"""
# By default these are set but they can change
var device:String = "PC"
var mute_sound:bool = false
var mute_music:bool = false

var current_level

#Mobile
var joystick_rot = 0


"""============================================================================
Language
============================================================================"""
var farsi:bool = false

export(String, MULTILINE) var credit_text_en
export(String, MULTILINE) var credit_text_fa
export(String, MULTILINE) var share_score_en
export(String, MULTILINE) var share_score_fa

#When language button is toggled in main menu scene, switch all members of the "Language" group to
#the selected language's values. Index 0 = English, 1 = Farsi. 
var Language:Dictionary = {
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
						"GameWonLabel":["GAME WON","یزوریپ"],
						"ScoreLabel":["Score: 00000","هرمن: 000000"],
						"ScoreCopied":["SCORE COPIED","دش یپک هرمن"], 
						"GameOverLabel":["GAME OVER","یدرم وت"],
						"PlayAgainButton":["Play Again","هرابود"],
						"ReturnToMenuButton":["Main Menu","ونم"]
						}
var LanguageBanner:Array = [
								"res://data/images/gui/banner_en.png", 
								"res://data/images/gui/banner_fa.png"
							]



"""============================================================================
Gameplay - Bounds
============================================================================"""
#These will be set from Level.gd.

# Outside of these bounds, effects and dead enemies will queue_free
var upper_bounds:Vector2 = Vector2.ZERO
var lower_bounds:Vector2 = Vector2.ZERO

# The player cannot travel outside of these bounds
var player_upper_bounds:Vector2 = Vector2.ZERO
var player_lower_bounds:Vector2 = Vector2.ZERO

#The maximum reach of the mouse (not applicable to mobile). 
var mouse_max_y:int = 0

#Containers of position variables set from Level.gd
var enemy_spawns
var die_targets

"""============================================================================
Gameplay - Stats
============================================================================"""
#Score
var score:int = 0
var high_score:int = 0

#Player/Horse
var player
var playerhorse_pos:Vector2 = Vector2()
var playerhorse_vel:Vector2 = Vector2()
var playerhorse_rot:float = 0
var player_pos:Vector2 = Vector2()
var player_starting_health:int = 100
var player_health:int = player_starting_health
var playerhorse_starting_health:int = 100
var playerhorse_health:int = player_starting_health
var player_bleeding:bool = false
var player_mag_cap:int = 15


#Enemy
var enemy_speed_normal:int = 110

#Enemy boid variables
var target_force:float = 0.04
var cohesion_force:float = 0.00
var alignment_force:float = 0.03
var separation_force:float = 0.04
var view_distance:float = 100
var avoid_distance:float = 110

#Bullet
var gunshots:Array = ["gunshot_1", "gunshot_2", "gunshot_3"] #Gunshot sound filenames
var gun_dmg_min:int = 50
var gun_dmg_max:int = 120
var bullet_primary_damage:int = 100	
var bullet_adtl_damage:int = 30

#Environment
var ground_vel:Vector2 = Vector2(0, -400)

#Waves
"""
	Key: 		
		u = solo unarmed,
		a = armed,
		du = duo unarmed
		da = duo armed
"""
var waves:Dictionary = {
				1:["u"],#["u"],#["u","u","u","u","u"
				2:["u","u"],
				3:["u","u","u","u"],
				4:["a"],
				5:["u","u","u","a"],
				6:["u","u","u","u","u","a","a"],
				7:["du"],
				8:["a","a","a","a"],
				9:["du","du","du"],
				10:["du","a","a","a"],
				11:["da","du","da","du"],
				12:["da","da","da","da"]
			}
			
"""============================================================================
Remote functions
============================================================================"""
func _enemy_remote_shoot(enemy):
	# This function is called from Level.gd because the enemy has a delay between
	# aiming and shooting. The reason it's not called locally is because of the use
	# of the yield function for this delay. Yield should not be used on a node that
	# has a chance of queueing free before the timeout.
	if weakref(enemy).get_ref():
		#Weakref checks to make sure the resource still exists.
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var rn = rng.randf_range(0.1, 0.7)
		yield(get_tree().create_timer(rn), "timeout")
		if weakref(enemy).get_ref():
			enemy._shoot()
	
func _reset_level_vars():
	#Upon game over, reset player vars in case the game is restarted.
	player_health = player_starting_health
	playerhorse_health = player_starting_health
	player_bleeding = false
	
