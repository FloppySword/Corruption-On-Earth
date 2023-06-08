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




func _ready():
	
	$Bottom/PlayButton.grab_focus()
	
	
	
func _process(delta):
	if Engine.editor_hint:
		setup()

func setup():
	$Title.text = title_text
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = title_font
	dynamic_font.size = title_font_size
	dynamic_font.outline_size = title_outline_size
	dynamic_font.outline_color = title_outline_color
	dynamic_font.extra_spacing_char = title_char_spacing
	dynamic_font.extra_spacing_space = title_space_spacing
	$Title.add_font_override("font",dynamic_font)
	$Title.add_color_override("font_color",title_font_color)
	if title_shadow_on:
		$Title.add_color_override("font_color_shadow",title_shadow_color)
		$Title.add_constant_override("shadow_offset_x",title_shadow_x_offset)
		$Title.add_constant_override("shadow_offset_y",title_shadow_y_offset)
		$Title.add_constant_override("shadow_as_outline",title_shadow_as_outline)
	else:
		$Title.remove_color_override("font_color_shadow")
		$Title.remove_color_override("shadow_offset_x")
		$Title.remove_color_override("shadow_offset_y")
		$Title.remove_color_override("shadow_as_outline")

	$Background.texture = background_texture
	



func _on_PlayButton_pressed():
	pass # Replace with function body.


func _on_OptionsButton_pressed():
	$SubMenus.open_submenu("settings")


func _on_CreditsButton_pressed():
	$SubMenus.open_submenu("credits")


func _on_ExitButton_pressed():
	pass # Replace with function body.


func _on_EnglishButton_pressed():
	pass # Replace with function body.


func _on_FarsiButton_pressed():
	pass # Replace with function body.


func _on_RichTextLabel_meta_clicked(meta):
	OS.shell_open(meta)
