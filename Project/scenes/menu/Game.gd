extends Node

var Level = preload("res://scenes/level/Level1.tscn")
var level

onready var main_menu = $MainMenu

func _ready():
	main_menu.connect("start_level", self, "_start_level")


func _start_level():
	#get_tree().paused = true
	#if !level:
	
	level = Level.instance()
	add_child(level)

	level.connect("game_over", main_menu, "_GameOver")
	level.connect("game_won", main_menu, "_GameWon")
		

	#get_tree().paused = false
	


