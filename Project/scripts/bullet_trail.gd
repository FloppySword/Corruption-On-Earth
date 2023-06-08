extends Sprite

onready var animation = get_node("AnimationPlayer")


	
func _physics_process(delta):
	if global.AR_active == true:
		if global.pistol_active == false:
			set_scale(Vector2(0.5, 0.5))
	elif global.pistol_active == true:
		if global.AR_active == false:
			set_scale(Vector2(0.1, 0.1))

func _on_AnimationPlayer_finished():
	queue_free()
