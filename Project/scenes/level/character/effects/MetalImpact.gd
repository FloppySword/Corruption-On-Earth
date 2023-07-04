extends AnimatedSprite

var tire:bool = false
var starting_x:float = 0

var ricochet_sounds:Array = [
							"res://data/sound/effects/metal/ricochet1.wav",
							"res://data/sound/effects/metal/ricochet2.wav",
							"res://data/sound/effects/metal/ricochet3.wav"
							]

func _set_audio():
	# Assign one of three possible ricochet sounds and play it
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var idx = rng.randi_range(0,2)
	var sfx = load(ricochet_sounds[idx]) 
	$AudioStreamPlayer2D.stream = sfx
	$AudioStreamPlayer2D.play()
	

func _process(delta):
	if tire:
		# If no starting_x yet, set it to the global position.
		# Then give the effect velocity since the tire popped
		# in-place (and is falling behind the moving motorcycle).
		if starting_x:
			global_position.x = starting_x
			global_position += Global.ground_vel * delta
		else:
			starting_x = global_position.x

func _on_MetalImpact_animation_finished():
	# Keep the tire in scene until it automatically queues free
	# as a child of the effects container in Level1.tscn once it
	# passes the global bounds.
	if !tire:
		queue_free()
