tool
# With "tool" declared , this allows the below export variables
# to be updated instantly in the inspector. No need to run the 
# project to see your changes. 

extends TextureButton

#Button text and arrow visibility/texture
export(String) var text = "Text Button"
export(int) var arrow_margin_from_center = 100
export(Texture) var arrow_texture = null
export(bool) var arrows_visible = true

#Font settings
export(DynamicFontData) var font = null
export(int,8,48,2) var font_size = 16
export(Color) var font_color
export(bool) var font_color_change_focus = false
export(Color) var font_color_focused

func _ready():
	setup()
	hide_focus()
	set_focus_mode(true)

func setup():
	# Made into a function because called more than once (see _process function)
	$RichTextLabel.bbcode_text = "[center] %s [/center]" % [text]
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = font
	dynamic_font.size = font_size
	$RichTextLabel.add_font_override("normal_font",dynamic_font)
	$RichTextLabel.add_color_override("default_color",font_color)
	$LeftArrow.texture = arrow_texture
	$RightArrow.texture = arrow_texture
	for arrow in [$LeftArrow, $RightArrow]:
		arrow.visible = arrows_visible
	
func _process(delta):
	# Shows the current state of the button based on changes to export variables at top
	# (Makes it unnecessary to start game to see changes)
	if Engine.editor_hint:
		setup()
		show_focus()
	
func show_focus():
	if arrows_visible:
		for arrow in [$LeftArrow, $RightArrow]:
			arrow.visible = true
			arrow.global_position.y = rect_global_position.y + (rect_size.y / 3.0)
			
		var center_x = rect_global_position.x + (rect_size.x / 2)
		$LeftArrow.global_position.x = center_x - arrow_margin_from_center
		$RightArrow.global_position.x = center_x + arrow_margin_from_center
	if font_color_change_focus:
		$RichTextLabel.add_color_override("default_color",font_color_focused)
	
func hide_focus():
	for arrow in [$LeftArrow, $RightArrow]:
		arrow.visible = false
	
	$RichTextLabel.add_color_override("default_color",font_color)
	
	
	
#These toggle whether the button is highlighted if the mouse goes over it.
func _on_MenuButton_focus_entered():
	show_focus()

func _on_MenuButton_focus_exited():
	hide_focus()

func _on_MenuButton_mouse_entered():
	grab_focus()

#func _on_MenuButton_mouse_exited():
#	hide_focus()
