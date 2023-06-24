tool
extends Control

export(Texture) var background_texture = null#preload("res://icon.png")

export(String) var title_text = "Title"
export(DynamicFontData) var title_font = null
export(int,8,144,2) var title_font_size = 48
export(Color) var title_font_color
export(int,0,100,1) var title_char_spacing = 0
export(int,0,100,1) var title_space_spacing = 0

export(int,0,100,1) var title_outline_size = 0
export(Color) var title_outline_color

export(bool) var title_shadow_on = false
export(Color) var title_shadow_color
export(int,0,100,1) var title_shadow_x_offset = 0
export(int,0,100,1) var title_shadow_y_offset = 0
export(bool) var title_shadow_as_outline = false


var link_instagram = 'https://www.instagram.com/toomajofficial/'
var link_soundcloud = 'https://soundcloud.com/toomajsalehi'
var link_youtube = 'https://www.youtube.com/watch?v=oc0QAY-hy38'
var link_about = 'https://freetoomajsalehi.com/'
var link_sign = 'https://www.change.org/p/free-iranian-protest-rapper-toomaj-salehi-freetoomajsalehi-freetoomaj'

var Level = preload("res://scenes/level/Level1.tscn")
var level


func _ready():
	
	$Bottom/PlayButton.grab_focus()
	
	

func change_language(idx):
	Global.farsi = idx
	$Banner.texture = load(Global.LanguageBanner[idx])
	for item in get_tree().get_nodes_in_group("Language"):
		item.text = Global.Language[item.name][idx]
		if item.is_in_group("MenuButton"):
			item.setup()
	
	OS.shell_open('https://www.ac4a.net/')


func _on_PlayButton_pressed():
	get_tree().paused = true
	
	level = Level.instance()
	add_child(level)

	level.connect("game_over", self, "_GameOver")
	level.connect("game_won", self, "_GameWon")

	yield(get_tree().create_timer(1.75), "timeout")
	get_tree().paused = false
	
func _GameOver():
	$GameEnded/TabContainer.current_tab = 1
	$GameEnded/ButtonsContainer/PlayAgainButton.text = "Try Again"
	$GameEnded.popup()

func _GameWon():
	$GameEnded/TabContainer.current_tab = 0
	$GameEnded/ButtonsContainer/PlayAgainButton.text = "Play Again"
	$GameEnded.popup()


func _on_OptionsButton_pressed():
	$SubMenus.open_submenu("settings")


func _on_CreditsButton_pressed():
	$SubMenus.open_submenu("credits")


func _on_ExitButton_pressed():
	pass # Replace with function body.


func _on_EnglishButton_pressed():
	if Global.farsi:
		$HBoxContainer/FarsiButton.pressed = false
		change_language(0)
	else:
		$HBoxContainer/EnglishButton.pressed = true
		$HBoxContainer/FarsiButton.pressed = false
		



func _on_FarsiButton_pressed():
	if !Global.farsi:
		$HBoxContainer/EnglishButton.pressed = false
		change_language(1)
	else:
		$HBoxContainer/EnglishButton.pressed = false
		$HBoxContainer/FarsiButton.pressed = true


func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)


func _on_PlayAgainButton_button_up():
	_on_PlayButton_pressed()
	$GameEnded.hide()


func _on_ReturnToMenuButton_button_up():
	get_tree().paused = false
	$GameEnded.hide()


func _on_YouTube_pressed():
	pass # Replace with function body.


func _on_SoundCloud_pressed():
	pass # Replace with function body.


func _on_Instagram_pressed():
	pass # Replace with function body.


func _on_LearnMoreButton_pressed():
	pass # Replace with function body.


func _on_SignPetitionButton_pressed():
	pass # Replace with function body.



