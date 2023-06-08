extends Node

var first_level = preload("res://scenes/level1.tscn")
var second_level = preload("res://scenes/level2.tscn")
var third_level = preload("res://scenes/level3.tscn")
var endless_level = preload("res://scenes/testing_level.tscn")


onready var playbutton = get_node("main_container/smallcontainer1/play")
onready var controlsbutton = get_node("main_container/smallcontainer1/controls")
onready var creditsbutton = get_node("main_container/smallcontainer1/credits")
onready var level1button = get_node("level_1")
onready var level2button = get_node("level_2")
onready var level3button = get_node("level_3")
onready var endlessbutton = get_node("endless")
onready var soundonbutton = get_node("sound_on")
onready var soundoffbutton = get_node("sound_off")
onready var musiconbutton = get_node("music_on")
onready var musicoffbutton = get_node("music_off")
onready var backbutton = get_node("back")
onready var quitbutton = get_node("main_container/smallcontainer2/quit")

onready var credits_screen = get_node("credits_screen")
onready var controls_screen = get_node("controls_screen")
onready var background = get_node("background")


func _ready():
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	pass

func _input(event):
	if event.is_action_pressed("ui_exit"):
		get_tree().quit()
	


func _on_play_pressed():
	playbutton.hide()
	controlsbutton.hide()
	creditsbutton.hide()
	endlessbutton.show()
	level1button.show()
	level2button.show()
	level3button.show()
	backbutton.show()
	quitbutton.hide()
	for s in get_tree().get_nodes_in_group("sound_buttons"):
		s.hide()


func _on_level_1_pressed():
	var omg = first_level.instance()
	add_child(omg)
	for b in get_tree().get_nodes_in_group("menu_buttons"):
		b.hide()
	background.hide()
	
func _on_level_2_pressed():
	var lol = second_level.instance()
	add_child(lol)
	for b in get_tree().get_nodes_in_group("menu_buttons"):
		b.hide()
	background.hide()
	
func _on_level_3_pressed():
	var wtf = third_level.instance()
	add_child(wtf)
	for b in get_tree().get_nodes_in_group("menu_buttons"):
		b.hide()
	background.hide()

func _on_controls_pressed():
	for b in get_tree().get_nodes_in_group("menu_buttons"):
		b.hide()
	controls_screen.show()
	backbutton.show()
	


func _on_credits_pressed():
	for b in get_tree().get_nodes_in_group("menu_buttons"):
		b.hide()
	credits_screen.show()
	backbutton.show()


func _on_sound_on_pressed():
	global.mute_sound = true
	soundonbutton.hide()
	soundoffbutton.show()


func _on_sound_off_pressed():
	global.mute_sound = false
	soundoffbutton.hide()
	soundonbutton.show()


func _on_music_on_pressed():
	global.mute_music = true
	musiconbutton.hide()
	musicoffbutton.show()


func _on_music_off_pressed():
	global.mute_music = false
	musicoffbutton.hide()
	musiconbutton.show()

func _on_back_pressed():
	go_back()
	
	
	
	
func go_back():
	for s in get_tree().get_nodes_in_group("screens"):
		s.hide()
	for l in get_tree().get_nodes_in_group("level_buttons"):
		l.hide()
	for b in get_tree().get_nodes_in_group("main_menu_buttons"):
		b.show()
	backbutton.hide()
	if global.mute_music == false:
		musiconbutton.show()
	else:
		musicoffbutton.show()
	if global.mute_sound == false:
		soundonbutton.show()
	else:
		soundoffbutton.show()




func _on_quit_pressed():
	get_tree().quit()
