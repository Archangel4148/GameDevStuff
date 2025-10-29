extends Node2D

var tutorial_zone_triggered = false
var double_jump_triggered = false
var finish_triggered = false
var leap_of_faith_triggered = false

func _ready() -> void:
	# Start the background music
	MusicManager.play_track("res://assets/music/level_1_music.wav")

func _on_tutorial_next_trigger_body_entered(_body: Node2D) -> void:
	if not tutorial_zone_triggered:
		var tween = create_tween()
		tween.tween_property($"Background/Swap Colors Text", "modulate:a", 0, 0.5)  # fade out
		tween.tween_property($"Background/Matching Colors Text", "modulate:a", 1, 0.5)  # fade in
		tutorial_zone_triggered = true

func _on_finish_trigger_body_entered(_body: Node2D) -> void:
	if not finish_triggered:
		MusicManager._fade_out_then_play("res://assets/sound_effects/victory_sound.wav", 0.5)
		var tween = create_tween()
		tween.tween_property($"Background/Finish Label", "modulate:a", 1, 0.5)  # fade in
		finish_triggered = true


func _on_leap_of_faith_trigger_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property($"Background/Leap of Faith Label", "modulate:a", 1, 0.5)  # fade in


func _on_double_jump_trigger_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property($"Background/Double Jump Label", "modulate:a", 1, 0.5)  # fade in
