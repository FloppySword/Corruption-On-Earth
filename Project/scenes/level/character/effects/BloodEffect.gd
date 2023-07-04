extends AnimatedSprite

var type:String = ""
	
	
func _initiate(pos:Vector2, _type:String):
	# Give the effect a random rotation
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	global_rotation = rng.randi_range(-180, 180)
	
	global_position = pos
	type = _type
	# Set scale according to type. The first three are gunshots.
	# The last are drops of blood, similar to tiremarks but red.
	# Currently only utilizing the gunshots, but the drops could be
	# used for a bleeding effect.
	if type == "gunshot":
		scale = Vector2(0.4, 0.4)
		play("gunshot")
	elif type == "headshot":
		scale = Vector2(0.6, 0.6)
		play("gunshot")
	elif type == "gunshot_player":
		scale = Vector2(0.7, 0.7)
		play("gunshot")
	else:
		rng.randomize()
		var frame = rng.randi_range(0,2)
		set_frame(frame)

func _on_BloodEffect_animation_finished():
	# Fires after the animation has finished.
	# If this isn't for a gunshot/headshot, do nothing.
	
	if type == "gunshot" || type == "headshot":
		queue_free()
	else:
		if (type == "gunshot_player" && Global.player_health <= 0) ||\
		(type == "gunshot_horse" && Global.playerhorse_health):
			# If the gunshot killed the player or the horse, reset 
			# the animation by setting the frame back to 0
			frame = 0
		else:
			queue_free()

