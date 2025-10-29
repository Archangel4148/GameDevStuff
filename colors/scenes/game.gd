extends Node2D

var can_be_paused = false
var is_paused = false

func _ready() -> void:
	# Pause everything on start, and show the menu
	get_tree().paused = true
	$"UI/Main Menu".show()
	
	# Hide the pause menu 
	$"UI/Pause Menu".hide()

func _input(event):
	if event.is_action_pressed("pause"):
		pause_unpause()

func _on_main_menu_start_game() -> void:
	get_tree().paused = false
	can_be_paused = true

func pause_unpause() -> void:
	if not can_be_paused:
		return
	if is_paused:
		# Unpause the game and hide the pause menu
		get_tree().paused = false
		$"UI/Pause Menu".hide()
		is_paused = false
	else:
		# Pause the game and display the pause menu
		get_tree().paused = true
		$"UI/Pause Menu".show_pause_menu()
		is_paused = true

func _on_pause_menu_resume_game() -> void:
	pause_unpause()

func _on_music_volume_slider_value_changed(value: float) -> void:
	MusicManager.volume_linear = value / 100

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	$"Color Boi/Sound Effect Player".volume_linear = value / 100
