extends AnimatedSprite


func _on_MetalImpact_animation_finished():
	queue_free()
