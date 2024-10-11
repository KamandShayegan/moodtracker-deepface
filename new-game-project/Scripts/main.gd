extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Link for converting image to base 64: https://www.reddit.com/r/godot/comments/g6ih9t/how_do_i_format_images_as_either_binary_file_or/
# This function is connected to the button up event of the LoadImageButton
func _on_load_image_button_up() -> void:
	print('Loading image')
	%FileDialog.popup()




func _on_file_dialog_file_selected(path: String) -> void:
	#Setting the image texture
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	%Image.texture = image_texture
	
	#Making the API call, it needs to treat the image as a file to make the proper transformation, that's why it's separete from the other code
	var file = FileAccess.open(path, FileAccess.READ)
	var base_64_data = Marshalls.raw_to_base64(file.get_buffer(file.get_length()))
	print(base_64_data)
