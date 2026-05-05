extends Control




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_debug_button_pressed() -> void:
	# Change scenes to debug menu scene
	get_tree().change_scene_to_file("res://Scenes/DebugMenu.tscn")
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	# Exit the game
	get_tree().quit()


func _on_scoring_tool_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/scoring_tool.tscn")

	pass # Replace with function body.
