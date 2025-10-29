extends Node2D

const LEVEL_PATHS = [
	"res://scenes/level_1.tscn",
]

var can_be_paused = false
var is_paused = false

# The currently loaded level
var current_level_index: int = 0
var current_level_scene: Node = null

func _ready() -> void:
	# Show the main menu on startup
	main_menu()

func _input(event):
	if event.is_action_pressed("pause"):
		pause_unpause()

func main_menu():
	# Delete the loaded scene (if any)
	if current_level_scene:
		current_level_scene.queue_free()
		current_level_scene = null
	
	# Pause everything and show the menu
	get_tree().paused = true
	$"UI/Main Menu".move_to_front()
	$"UI/Main Menu".show()
	
	# Hide the pause and level complete menus
	$"UI/Pause Menu".hide()
	$"UI/Level Complete Screen".hide()

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
		$"UI/Pause Menu".show_pause_menu()
		$"UI/Pause Menu".move_to_front()
		get_tree().paused = true
		is_paused = true

func load_level(scene_path: String):
	# Unload the previous level (if any)
	if current_level_scene:
		current_level_scene.queue_free()
	
	# Update the current level with an instance of the provided level scene
	current_level_scene = load(scene_path).instantiate()
	add_child(current_level_scene)
	# Move the level to the back (behind player/UI)
	move_child(current_level_scene, 0)
	
	# Move the player to the start position and reset their color
	$"Color Boi".position = current_level_scene.start_pos
	$"Color Boi".set_color(0)
	
	# Wait two frames to ensure player was properly moved
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# Connect the level finish signal
	current_level_scene.level_complete.connect(_on_level_complete)
	
	# The level can now do final setup
	current_level_scene.setup()

func _on_main_menu_start_game() -> void:
	get_tree().paused = false
	can_be_paused = true
	# Load level 1
	load_level(LEVEL_PATHS[0])

func _on_pause_menu_resume_game() -> void:
	pause_unpause()

func _on_music_volume_slider_value_changed(value: float) -> void:
	MusicManager.volume_linear = value / 100

func _on_sfx_volume_slider_value_changed(value: float) -> void:
	$"Color Boi/Sound Effect Player".volume_linear = value / 100

func _on_level_complete(info: Array):
	can_be_paused = false
	get_tree().paused = true
	# Pass the level completion info to the level complete screen
	$"UI/Level Complete Screen".level_complete(info)

func _on_level_complete_screen_main_menu() -> void:
	# Return to the main menu
	main_menu()

func _on_level_complete_screen_next_level() -> void:
	# If possible, load the next level
	var next_index = current_level_index + 1
	if next_index < LEVEL_PATHS.size():
		load_level(LEVEL_PATHS[next_index])
	else:
		print("Could not find level: " + str(next_index + 1))

func _on_pause_menu_main_menu() -> void:
	main_menu()

func _on_pause_menu_restart_level() -> void:
	pause_unpause()
	# Re-load the current level
	load_level(LEVEL_PATHS[current_level_index])
