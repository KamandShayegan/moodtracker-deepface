extends Control

var ongoing_transition: String

func change_scene(new_scene: String) -> void:
	print('Chaging scene')
	var tween = create_tween()
	ongoing_transition = new_scene
	%AnimationPlayer.play("FadeIn")
	await %AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(new_scene)
	%AnimationPlayer.play_backwards("FadeIn")
