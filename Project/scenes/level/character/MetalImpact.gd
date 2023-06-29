extends AnimatedSprite

var tire = false
var starting_x = null

var ricochet_sounds = [
						"res://data/sound/effects/metal/ricochet1.wav",
						"res://data/sound/effects/metal/ricochet2.wav",
						"res://data/sound/effects/metal/ricochet3.wav"
						]

func _set_audio():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var idx = rng.randi_range(0,2)
	var sfx = load(ricochet_sounds[idx]) 
	#sfx.set_loop(false)
	$AudioStreamPlayer2D.stream = sfx
	$AudioStreamPlayer2D.play()
	#SoundManager.play_sound($AudioStreamPlayer2D.stream)

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
