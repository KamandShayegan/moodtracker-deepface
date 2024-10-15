extends Control

var take_photo_script = preload("res://Scripts/take_photo.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_sign_up_button_up() -> void:
	SceneTransitions.change_scene("res://Scenes/fill_name.tscn")


func _on_login_button_up() -> void:
	take_photo_script.first_time = false
	SceneTransitions.change_scene("res://Scenes/take_photo.tscn")
