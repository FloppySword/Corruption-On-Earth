extends AnimatedSprite

var tire = false
var starting_x = null

func _process(delta):
	if tire:
		if starting_x:
			global_position.x = starting_x
			global_position += Global.ground_vel * delta
		else:
			starting_x = global_position.x

func _on_MetalImpact_animation_finished():
	if !tire:
		queue_free()
