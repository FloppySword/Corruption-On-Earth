extends Node

"""
Game.tscn is the main scene of the project. Aside from autoload scenes, it is the first 
scene to fire in the SceneTree on start-up.

The basic structure of the game after staart-up is as follows:
	
	Pre-Gameplay:
	* The main menu displays, as is the only child node of this scene.
	* Upon hitting the "Play" button, a level scene is instanced and added to
	  this scene. It hides the menu scene because it's the newer child.
	* Submenus such as for options or credits appear as pop-ups.
	
	Gameplay:
	* The player comes pre-loaded with the instanced level scene.
	* Enemies spawn outside of the viewport in waves. Once all enemies in a wave 
	  are killed, the next wave of enemies spawns. 
	* Once all waves are defeated, the level is erased and a pop-up appears (a child 
	  of the menu scene) indicating that the player has won.
	* If the player or the horse lose all of their health, the level is also erased
	  and the same pop-up appears, but indicating that the player has lost. 
	
This is, of course, a gross simplification.
"""

# "Level" is a static scene variable
# "level" starts as null but is set to the current level once the game begins.
var Level = preload("res://scenes/level/Level1.tscn")
var level

onready var main_menu = $MainMenu

func _ready():
	# Connects the child menu scene's "start_level" signal with this scene's
	# "_start_level" function.
	# So when the menu scene emits that signal, the below function is called.
	main_menu.connect("start_level", self, "_start_level")


func _start_level():
	#Create a new level
	level = Level.instance()
	add_child(level)
	
	# Allows the level to communicate with the menu scene once it's ended, telling
	# it which of the two end-game screens ti display.
	level.connect("game_over", main_menu, "_GameOver")
	level.connect("game_won", main_menu, "_GameWon")



