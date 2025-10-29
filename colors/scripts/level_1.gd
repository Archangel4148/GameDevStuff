extends Node2D

signal level_complete(info: Array)

# Set the player spawn position to the marker location
@onready var start_pos: Vector2 = $PlayerStart.global_position

var time_elapsed = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Track time spent in the level (stop tracking while paused)
	if not get_tree().paused:
		time_elapsed += delta

func setup():
	# Make trigger connections
	$"Tutorial Next Trigger".body_entered.connect(_on_tutorial_next_trigger_body_entered)
	$"Double Jump Trigger".body_entered.connect(_on_double_jump_trigger_body_entered)
	$"Leap of Faith Trigger".body_entered.connect(_on_leap_of_faith_trigger_body_entered)
	$"Finish Trigger".body_entered.connect(_on_finish_trigger_body_entered)
	
	# Start the background music
	MusicManager._fade_out_then_play("res://assets/music/level_1_music.wav", 0.5)

func _on_tutorial_next_trigger_body_entered(_body: Node2D) -> void:
	$"Tutorial Next Trigger".set_deferred("monitoring", false)
	var tween = create_tween()
	tween.tween_property($"Background/Swap Colors Text", "modulate:a", 0, 0.5)  # fade out
	tween.tween_property($"Background/Matching Colors Text", "modulate:a", 1, 0.5)  # fade in

func _on_finish_trigger_body_entered(_body: Node2D) -> void:
	$"Finish Trigger".set_deferred("monitoring", false)
	MusicManager._fade_out_then_play("res://assets/sound_effects/victory_sound.wav", 0.5)
	var tween = create_tween()
	tween.tween_property($"Background/Finish Label", "modulate:a", 1, 0.5)  # fade in

	# Wait a few seconds before finishing the level
	var timer := Timer.new()
	timer.wait_time = 4.5
	timer.one_shot = true
	timer.process_mode = Node.PROCESS_MODE_PAUSABLE  # pauses with the game
	add_child(timer)
	timer.start()

	await timer.timeout

	# Clean up the timer node
	timer.queue_free()
	finish_level()

func _on_leap_of_faith_trigger_body_entered(_body: Node2D) -> void:
	$"Leap of Faith Trigger".set_deferred("monitoring", false)
	var tween = create_tween()
	tween.tween_property($"Background/Leap of Faith Label", "modulate:a", 1, 0.5)  # fade in

func _on_double_jump_trigger_body_entered(_body: Node2D) -> void:
	$"Double Jump Trigger".set_deferred("monitoring", false)
	var tween = create_tween()
	tween.tween_property($"Background/Double Jump Label", "modulate:a", 1, 0.5)  # fade in

func finish_level():
	MusicManager.stop_music()
	var info = [
		"Time: " + str("%.2f" % time_elapsed) + "s",
	]
	level_complete.emit(info)
