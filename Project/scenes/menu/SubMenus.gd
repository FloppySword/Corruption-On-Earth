tool
extends Popup

#export(String) var text = "Text Button"
#export(int) var arrow_margin_from_center = 100
#export(Texture) var arrow_texture = null#preload("res://icon.png")
#export(bool) var arrows_visible = true

export(DynamicFontData) var font = null
export(int,8,48,2) var font_size = 16
export(Color) var font_color
export(bool) var font_color_change_focus = false
export(Color) var font_color_focused


func _ready():
	if OS.get_name() != "HTML5":
		$TabContainer/Credits/MarginContainer/VBoxContainer/CreditsBody.connect("meta_clicked", self, "_on_RichTextLabel_meta_clicked")
		
	setup()

func _process(delta):
	if Engine.editor_hint:
		setup()
		
func setup():
	pass
	
func open_submenu(type):
	if type == "settings":
		$TabContainer.current_tab = 0
	else:
		$TabContainer.current_tab = 1
	popup()
	
	
func _on_CloseButton_pressed():
	hide()






func _on_MasterSlider_value_changed(value):
	pass # Replace with function body.


func _on_MusicSlider_value_changed(value):
	pass # Replace with function body.


func _on_SFXSlider_value_changed(value):
	pass # Replace with function body.
