extends Control

var hue = 0
signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	# Loop the title through hues
	hue = fmod(hue + delta * 0.1, 1.0)  # ("float modulo")
	$Title.modulate = Color.from_hsv(hue, 1.0, 1.0)


func _on_start_pressed() -> void:
	emit_signal("start_game")
	hide()
