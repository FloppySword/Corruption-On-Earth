extends Node


onready var track1 = $Music/Track1.stream
onready var track2 = $Music/Track2.stream
onready var track3 = $Music/Track3.stream
onready var track4 = $Music/Track4.stream
onready var track5 = $Music/Track5.stream
onready var track6 = $Music/Track6.stream


func _ready():
	SoundManager.set_default_music_bus("Music")
	SoundManager.set_default_sound_bus("Sound")
	SoundManager.set_default_ui_sound_bus("Sound")
	
	for track_player in $Music.get_children():
		track_player.connect("finished", self, "_play_next_song")
	
	SoundManager.play_music(track2)

func _process(delta):
	if !SoundManager.is_music_playing():
		_play_next_song()
	

func _play_next_song():
	print(SoundManager.get_last_played_music_track())
	SoundManager.play_music(track3)
