extends Node

# The playlist will contain the music "tracks" (AudioStreamPlayers) 
# which are stored as children of the Music node.
var playlist:Array = []

# This counter keeps tabs on how many songs have played.
var play_count:int = 0

func _ready():
	# Set the Sound Manager addon's buses to the buses in the project.
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("Sound")
	SoundManager.set_default_ui_sound_bus("Sound")
	
	
	for i in range(0, $Music.get_child_count()):
		var track_player = $Music.get_child(i)
		#Add the track to the playlist
		playlist.append(i)
		#Connect the track's finished signal to the below _play_next_song function
		track_player.connect("finished", self, "_play_next_song")
	
	# Shuffle the playlist so that every song has an equal chance of playing on
	# game startup. 
	randomize()
	playlist.shuffle()

func _process(delta):
	# If the last song has finished playing
	if !SoundManager.is_music_playing():
		_play_next_song()
		

func _play_next_song():
	# If all songs have played at least once, restart playlist.
	if play_count == playlist.size():
		play_count = 0
		
	var next_track = $Music.get_child(playlist[play_count])
	SoundManager.play_music(next_track.stream)
	play_count += 1
	
	#print(SoundManager.get_last_played_music_track())
	
