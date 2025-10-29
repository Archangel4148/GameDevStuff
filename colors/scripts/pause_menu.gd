extends Control

signal resume_game
signal restart_level
signal main_menu

var can_key_close = false

var hue = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	# Allow unpausing with hotkey
	if can_key_close and Input.is_action_just_pressed("pause"):
		emit_signal("resume_game")
		hide()
		can_key_close = false
	
	# Fade the color of the grab areas
	hue = fmod(hue + delta * 0.1, 1.0)
	$"Music Volume Slider".get_theme_stylebox("grabber_area").bg_color = Color.from_hsv(hue, 1, 1)
	$"SFX Volume Slider".get_theme_stylebox("grabber_area").bg_color = Color.from_hsv(hue, 1, 1)

func _on_resume_button_pressed() -> void:
	emit_signal("resume_game")
	hide()
	can_key_close = false

func show_pause_menu():
	can_key_close = false
	show()
	# Don't instantly close again
	await wait_for_pause_key_release()
	can_key_close = true

func wait_for_pause_key_release() -> void:
	# Asynchronous helper
	while Input.is_action_pressed("pause"):
		await get_tree().process_frame

func _on_restart_button_pressed() -> void:
	restart_level.emit()

func _on_main_menu_button_pressed() -> void:
	main_menu.emit()
