extends Node2D


func _ready() -> void:
	# Pause everything on start, and show the menu
	get_tree().paused = true
	$"UI/Main Menu".show()


func _on_main_menu_start_game() -> void:
	get_tree().paused = false
