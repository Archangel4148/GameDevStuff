extends Node2D

func _ready() -> void:
	# Start the background music
	$"Background Music Player".play()

func fade_to_next_text():
	# Fade out current text
	var tween = create_tween()
	await tween.tween_property($"Background/Swap Colors Text", "modulate:a", 0, 0.5)  # fade out
	tween.tween_property($"Background/Matching Colors Text", "modulate:a", 1, 0.5)  # fade in


func _on_tutorial_next_trigger_body_entered(_body: Node2D) -> void:
	fade_to_next_text()


func _on_finish_trigger_body_entered(_body: Node2D) -> void:
	$"Background Music Player".stream = preload("res://assets/sound_effects/victory_sound.wav")
	$"Background Music Player".play()
	var tween = create_tween()
	tween.tween_property($"Background/Finish Label", "modulate:a", 1, 0.5)  # fade in
