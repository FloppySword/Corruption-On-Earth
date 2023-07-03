tool
# With "tool" declared , this allows the below export variables
# to be updated instantly in the inspector. No need to run the 
# project to see your changes.

extends Popup

export(DynamicFontData) var font = null
export(int,8,48,2) var font_size = 16
export(Color) var font_color
export(bool) var font_color_change_focus = false
export(Color) var font_color_focused

#func _ready():
	# This no longer seems necessary. Commenting out but leaving in script just in case.
	#if OS.get_name() != "HTML5":
		#$TabContainer/Credits/MarginContainer/VBoxContainer/CreditsBody.connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")
	
func open_submenu(type):
	if type == "settings":
		# Displays the settings tab
		$TabContainer.current_tab = 0
	else:
		# Displays the credits tab
		$TabContainer.current_tab = 1
	popup()

func _on_MasterSlider_value_changed(value):
	change_vol("Master", value)

func _on_MusicSlider_value_changed(value):
	change_vol("Music", value)

func _on_SFXSlider_value_changed(value):
	change_vol("Sound", value)

func change_vol(bus_name, value):
	#Identify correct bus whose volume needs changing
	var bus = AudioServer.get_bus_index(bus_name)
	
	#Convert from db to linear for a more intuitive volume range for the user
	var current_vol = db2linear(AudioServer.get_bus_volume_db(bus))
	
	#Convert back to db to set the actual bus volume.
	AudioServer.set_bus_volume_db(bus, linear2db(value))

func _on_CloseButton_pressed():
	hide()
