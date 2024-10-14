extends Control

var first_photo_script := preload("res://Scripts/first_photo.gd")
var regex := RegEx.new()

func _ready() -> void:
	regex.compile("[A-Za-Z]+")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if %TextEdit.text != '':
			get_tree().change_scene_to_file("res://Scenes/first_photo.tscn")
		else:
			return


func _on_text_edit_text_changed() -> void:
	var result = regex.search(%TextEdit.text)
	if !result: return
	%TextEdit.text = result.get_string()
	first_photo_script.user_name = result.get_string()
