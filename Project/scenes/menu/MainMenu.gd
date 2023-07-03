tool
# With "tool" declared , this allows the below export variables
# to be updated instantly in the inspector. No need to run the 
# project to see your changes. 

extends Control

export(Texture) var background_texture = null

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

#Link paths for the "Social" buttons
var link_instagram:String = 'https://www.instagram.com/toomajofficial/'
var link_soundcloud:String = 'https://soundcloud.com/toomajsalehi'
var link_youtube:String = 'https://www.youtube.com/watch?v=oc0QAY-hy38'
var link_about:String = 'https://freetoomajsalehi.com/'
var link_sign:String = 'https://www.change.org/p/free-iranian-protest-rapper-toomaj-salehi-freetoomajsalehi-freetoomaj'

signal start_level

func _ready():
	# Sets the language to English by default.
	change_language(0)

func change_language(idx):
	# Sets the Global.farsi boolean to either true (idx=1) or false(idx=0)
	Global.farsi = idx
	
	# All other text (labels and buttons chiefly) are now set to their values stored
	# in the dictionary Global.Language. Each of these nodes belongs to the "Language"
	# group, which is how they're linked together across the menu scene.
	for item in get_tree().get_nodes_in_group("Language"):
		item.text = Global.Language[item.name][idx]
		if item.is_in_group("MenuButton"):
			item.setup()
	
	# Correctly sets the contents of the credits based on the selected language
	# (See language variables in Global.gd)
	# This is set differently than all of the other text because
	# the "Global.credit_text" variables are export variables, since export vars
	# can be multi-line strings.
	var credits_body = $SubMenus/TabContainer/Credits/MarginContainer/VBoxContainer/CreditsBody
	if !Global.farsi:
		credits_body.bbcode_text = Global.credit_text_en
	else:
		credits_body.bbcode_text = Global.credit_text_fa
		
	# Similarly to credits_body in the , the banner (read: background)
	# texture is set to either the English or Farsi .png file. 
	$Banner.texture = load(Global.LanguageBanner[idx])
	

func _on_EnglishButton_pressed():
	# This and the below function are a contrived toggle setup 
	# using two separate button nodes.
	
	# Thus we need to make sure the opposing button isn't pressed at the 
	# same time as this one. 
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

func _on_OptionsButton_pressed():
	$SubMenus.open_submenu("settings")


func _on_CreditsButton_pressed():
	$SubMenus.open_submenu("credits")
	
	# Note: The below _on_RichTextLabel_meta_clicked function
	# applies to the credits body text.

func _on_RichTextLabel_meta_clicked(meta):
	# Signal that identifies hyperlink clicks and allows
	# for opening them in the device's browser.
	OS.shell_open(meta)

	#Note: this function is specifically for links in the credits body
	
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


func _on_PlayButton_pressed():
	var loading_screen = $LoadingScreen
	var spinner = $LoadingScreen/Panel/Spinner
	
	# Generate a random load time. Needs to be at least 1.5 seconds otherwise
	# the level starts too abruptly.
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rn = rng.randf_range(1.5, 2.5)
	
	# Start the loading spinner animation
	spinner.play("default")
	# Show the loading screen
	loading_screen.popup()
	
	# Let the loading screen spin for duration of above random float.
	yield(get_tree().create_timer(rn), "timeout")
	
	# Then reset the spinner's frame (for the next time a level is played)
	spinner.frame = 0
	spinner.play("finished")
	
	# Wait an additional half second before hiding the loading screen
	# and emitting the start_level signal.
	yield(get_tree().create_timer(0.5), "timeout")
	loading_screen.hide()
	self.hide()
	
	# This signal calls the _start_level function in Game.tscn.
	emit_signal("start_level")

func _GameOver():
	var score_copied_text = $GameEnded/TabContainer/GameWon/VBoxContainer/ScoreLabel/ShareButton/ScoreCopied
	var game_ended_tab = $GameEnded/TabContainer
	
	self.show()
	
	# In case it was copied in the last round, we don't want this to appear if 
	# the game was lost.
	score_copied_text.hide()
	
	# Display the 2nd tab (Game Over) in the GameEnded tab container.
	game_ended_tab.current_tab = 1
	$GameEnded.popup()

func _GameWon():
	var score_copied_text = $GameEnded/TabContainer/GameWon/VBoxContainer/ScoreLabel/ShareButton/ScoreCopied
	var game_ended_tab = $GameEnded/TabContainer
	var score_label = $GameEnded/TabContainer/GameWon/VBoxContainer/ScoreLabel
	
	self.show()

	# In case it was copied in the last round, we don't want this to appear  
	# until the player clicks the "share" button and the score is copied
	# to the clipboard.
	score_copied_text.hide()
	
	# Displays the player's score.
	score_label.text = Global.Language.ScoreLabel[int(Global.farsi)] + str(Global.score)

	# Display the 1st tab (Game Won) in the GameEnded tab container.
	game_ended_tab.current_tab = 0
	$GameEnded.popup()

func _on_ShareButton_button_up():
	var paragraph
	
	# Grab the relevant score-share string based on current language
	if Global.farsi:
		paragraph = Global.share_score_fa
	else:
		paragraph = Global.share_score_en
	
	# Replace the tilde with the score.
	paragraph = paragraph.replace("~", str(Global.score))
	# Copy content to clipboard.
	OS.set_clipboard(paragraph)
	
	# Indicate to player that they've copied the score.
	var score_copied_text = $GameEnded/TabContainer/GameWon/VBoxContainer/ScoreLabel/ShareButton/ScoreCopied
	score_copied_text.show()

func _on_PlayAgainButton_button_up():
	# Virtually press the play button to restart the game.
	_on_PlayButton_pressed()
	$GameEnded.hide()

func _on_ReturnToMenuButton_button_up():
	$GameEnded.hide()

func _on_ExitButton_pressed():
	get_tree().quit()
