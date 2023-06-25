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


signal start_level

func _ready():
	
	$Bottom/PlayButton.grab_focus()
	
	

func change_language(idx):
	Global.farsi = idx
	$Banner.texture = load(Global.LanguageBanner[idx])
	for item in get_tree().get_nodes_in_group("Language"):
		item.text = Global.Language[item.name][idx]
		if item.is_in_group("MenuButton"):
			item.setup()
	
	


func _on_PlayButton_pressed():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rn = rng.randf_range(1.5, 2.5)
	
	$LoadingScreen/Panel/Spinner.play("default")
	$LoadingScreen.popup()
	yield(get_tree().create_timer(rn), "timeout")
	$LoadingScreen/Panel/Spinner.frame = 0
	$LoadingScreen/Panel/Spinner.play("finished")
	yield(get_tree().create_timer(0.5), "timeout")
	$LoadingScreen.hide()
	self.hide()
	emit_signal("start_level")

	
func _GameOver():
	self.show()
	$GameEnded/TabContainer/GameWon/VBoxContainer/ScoreLabel/ShareButton/ScoreCopied.hide()
	$GameEnded/TabContainer.current_tab = 1
	$GameEnded.popup()

func _GameWon():
	self.show()
	$GameEnded/TabContainer/GameWon/VBoxContainer/ScoreLabel/ShareButton/ScoreCopied.hide()
	var score_label = $GameEnded/TabContainer/GameWon/VBoxContainer/ScoreLabel
	score_label.text = Global.Language.ScoreLabel[int(Global.farsi)] + str(Global.score)

	$GameEnded/TabContainer.current_tab = 0
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
	#get_tree().paused = false
	$GameEnded.hide()


func _on_YouTube_pressed():
	OS.shell_open(link_youtube)


func _on_SoundCloud_pressed():
	OS.shell_open(link_soundcloud)


func _on_Instagram_pressed():
	OS.shell_open(link_instagram)


func _on_LearnMoreButton_pressed():
	OS.shell_open(link_about)


func _on_SignPetitionButton_pressed():
	OS.shell_open(link_sign)



func _on_ShareButton_button_up():
	var paragraph
	if Global.farsi:
		paragraph = Global.share_score_fa
	else:
		paragraph = Global.share_score_en
	paragraph = paragraph.replace("~", str(Global.score))
	OS.set_clipboard(paragraph)
	$GameEnded/TabContainer/GameWon/VBoxContainer/ScoreLabel/ShareButton/ScoreCopied.show()
