tool
extends TextureButton

export(String) var text = "Text Button"
export(int) var arrow_margin_from_center = 100
export(Texture) var arrow_texture = null#preload("res://icon.png")
export(bool) var arrows_visible = true

export(DynamicFontData) var font = null
export(int,8,48,2) var font_size = 16
export(Color) var font_color
export(bool) var font_color_change_focus = false
export(Color) var font_color_focused


func _ready():
	setup()
	hide_focus()
	set_focus_mode(true)
	
#
func _process(delta):
	if Engine.editor_hint:
		setup()
		show_focus()
func setup():
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


func _on_MenuButton_focus_entered():
	show_focus()


func _on_MenuButton_focus_exited():
	hide_focus()


func _on_MenuButton_mouse_entered():
	grab_focus()
	
	
	
