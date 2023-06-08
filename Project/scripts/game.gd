#To do list for game:
# 1) add couple more rotations for player
# 2) add health and fire rate powerups
# 3) add ducking function
# 4) make it infinite
# 5) make a menu with 'start', 'controls', 'credits', music on/off setting, and high score
# 6) Make game over screen with score and high score and play again button


extends Node


onready var current_screen = get_node("current_screen")
onready var keypress_timer = get_node("keypress_timer")
#onready var level1 = get_node("level1")
onready var level = get_node("level2")
onready var score_label = get_node("current_screen/score_label")
onready var start_hs = get_node("current_screen/start_hs")
onready var go_score = get_node("current_screen/go_score")
onready var winner_hs = get_node("current_screen/winner_hs")
onready var tracklist = get_node("tracklist")

var prepare_game = false
var keypress_check = false



func _ready():
	randomize()
#	tracklist.get_child(randi()%4).play()
	start_hs.set_text("HIGH SCORE: "+str(global.high_score))
	start_hs.show()
	score_label.hide()
	go_score.hide()
	winner_hs.hide()
	if global.game_begun == false:
		current_screen.set_frame(0)
	if global.game_reset == true:
		current_screen.hide()
		global.game_reset = false
	
	set_process(true)
	set_process_input(true)
	
	
func _input(ev):
	
	if ev.type == InputEvent.KEY:
		if ev.is_action_pressed("ui_exit"):
			get_tree().quit()
		if global.game_begun == false:
			if current_screen.get_frame() == 0:
				if ev.is_action_pressed("ui_continue"):
					current_screen.set_frame(1)
					start_hs.hide()
					keypress_timer.start()
						
			if current_screen.get_frame() == 1:
				if keypress_check == true:
					if ev.is_action_pressed("ui_continue"):
						keypress_check = false
						current_screen.hide()
						global.game_begun = true
		elif global.game_begun == true:
			if current_screen.get_frame() == 2:
				if ev.is_action_pressed("ui_continue"):
					global.player_health = 105
					global.game_reset = true
			if current_screen.get_frame() == 3:
				if ev.is_action_pressed("ui_continue"):
					global.show_credits = true
					global.player_health = 105
					#global.boss_health = 140
					
			if current_screen.get_frame() == 4:
				if ev.is_action_pressed("ui_continue"):
					global.game_reset = true
					

	
func _process(delta):
	if global.score >= global.high_score:
		global.high_score = global.score
	score_label.set_text(str(global.score))
	if global.game_over == true:
		current_screen.set_frame(2)
		go_score.set_text("SCORE: "+str(global.score))
		go_score.show()
		start_hs.hide()
		current_screen.show()
		if global.game_reset == true:
			global.game_over = false
			global.score = 0
			get_tree().reload_current_scene()
	if global.game_won == true:
		current_screen.set_frame(3)
		score_label.show()
		winner_hs.set_text("HIGH SCORE: "+str(global.score))
		winner_hs.show()
		current_screen.show()
		global.game_won = false
	if global.show_credits == true:
		score_label.hide()
		start_hs.hide()
		winner_hs.hide()
		go_score.hide()
		current_screen.set_frame(4)
		if global.game_reset == true:
			current_screen.set_frame(0)
			global.show_credits = false
			global.score = 0
			get_tree().reload_current_scene()
			
			



func _on_keypress_timer_timeout():
	keypress_check = true
