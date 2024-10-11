extends Control
#onready vars load nodes at the very beginning and make sure they are available at any time
@onready var http_request = %HTTPRequest

var url = 'http://127.0.0.1:5000/analyze'

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
	var body = JSON.new().stringify({
		"img_path": str('data:image/jpeg;base64,',base_64_data),
		"actions": ["age", "gender", "emotion", "race"]
		})
	var headers: PackedStringArray = ['Content-type:application/json']
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response)
