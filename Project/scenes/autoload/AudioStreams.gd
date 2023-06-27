extends Node


var playlist = []
var play_count = 0

func _ready():
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("Sound")
	SoundManager.set_default_ui_sound_bus("Sound")
	
	for i in range(0, $Music.get_child_count()):
		var track_player = $Music.get_child(i)
			
		playlist.append(i)
		
		track_player.connect("finished", self, "_play_next_song")
		
	randomize()
	playlist.shuffle()


func _process(delta):
	if !SoundManager.is_music_playing():
		_play_next_song()
		

func _play_next_song():
	print(playlist)
	if play_count == playlist.size():
		play_count = 0
	var next_track = $Music.get_child(playlist[play_count])

	SoundManager.play_music(next_track.stream)
	print(SoundManager.get_last_played_music_track())
	play_count += 1
	
