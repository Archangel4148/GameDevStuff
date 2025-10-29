extends Node2D

signal level_complete(info: Array)

# Set the player spawn position to the marker location
@onready var start_pos: Vector2 = $PlayerStart.global_position

var time_elapsed = 0.0

func _process(delta: float) -> void:
	# Track time spent in the level (stop tracking while paused)
	if not get_tree().paused:
		time_elapsed += delta

func setup():
	# Make trigger connections here
	$"Example Trigger Zone".body_entered.connect(example_trigger)
	
	# Start the background music
	MusicManager._fade_out_then_play("res://assets/music/level_1_music.wav", 0.5)

func example_trigger(_body: Node2D) -> void:
	# Function to call when trigger zone is entered
	$"Example Trigger Zone".set_deferred("monitoring", false)  # Disable re-trigger (optional)
	print("Trigger zone entered!")

func finish_level():
	# On level finish, stop the music and send level-specific results
	MusicManager.stop_music()
	var info = [
		"Time: " + str("%.2f" % time_elapsed) + "s",
	]
	level_complete.emit(info)
