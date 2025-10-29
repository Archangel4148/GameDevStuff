extends Control

signal next_level
signal main_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_next_level_button_pressed() -> void:
	next_level.emit()

func _on_main_menu_button_pressed() -> void:
	main_menu.emit()

func level_complete(info: Array):
	# Parse and display level info
	var info_text = ""
	for string in info:
		info_text += string + "\n"
	$"Level Info".text = info_text
	
	# Show the screen
	show()
