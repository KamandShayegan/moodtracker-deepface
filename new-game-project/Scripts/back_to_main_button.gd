extends Button

@export_file('*.tscn') var previous_scene_path

func _on_button_up() -> void:
	SceneTransitions.change_scene(previous_scene_path)
