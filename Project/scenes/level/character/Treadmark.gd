extends Sprite

func init(pos, type):
	global_position = pos
	if type == "tire":
		scale = Vector2(4, 9)
	elif type == "hoof":
		scale = Vector2(2, 2)