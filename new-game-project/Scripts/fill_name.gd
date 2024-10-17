extends Control

var take_photo_script = preload("res://Scripts/take_photo.gd")
var regex := RegEx.new()

func _ready() -> void:
	regex.compile("[A-Za-Z]+")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if %TextEdit.text != '':
			take_photo_script.first_time = true
			take_photo_script.user_name = %TextEdit.text
			SceneTransitions.change_scene("res://Scenes/take_photo.tscn")
		else:
			return


#func _on_text_edit_text_changed() -> void:
	#var result = regex.search(%TextEdit.text)
	#if !result: return
	#%TextEdit.text = result.get_string()
	#take_photo_script.user_name = result.get_string()
