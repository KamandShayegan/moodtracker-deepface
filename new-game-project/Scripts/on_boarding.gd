extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_sign_up_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/fill_name.tscn")


func _on_login_button_up() -> void:
	pass # Replace with function body.
