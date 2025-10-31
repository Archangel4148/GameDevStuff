extends AudioStreamPlayer

var current_track_name: String = ""

func _ready():
	# Music should be allowed to play while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_track(track_path: String, fade_time: float = 0.5):
	if current_track_name == track_path:
		return  # Already playing this one

	current_track_name = track_path
	if playing:
		# Fade to the next song
		_fade_out_then_play(track_path, fade_time)
	else:
		stream = load(track_path)
		play()

func stop_music(fade_time: float = 0.5):
	# Stop the current music (either fade out or hard cut)
	if fade_time > 0:
		var tween = create_tween()
		tween.tween_property(self, "volume_db", -40, fade_time)
		tween.tween_callback(Callable(self, "stop"))
		tween.tween_property(self, "volume_db", 0, 0.0)
	else:
		stop()

func _fade_out_then_play(track_path: String, fade_time: float):
	var previous_volume = volume_db
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -40, fade_time)
	# When it finishes fading, play the next song
	tween.tween_callback(func ():
		stream = load(track_path)
		volume_db = previous_volume
		play()
	)
