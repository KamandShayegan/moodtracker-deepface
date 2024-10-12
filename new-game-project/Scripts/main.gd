extends Control
#onready vars load nodes at the very beginning and make sure they are available at any time
@onready var http_request = %HTTPRequest
@onready var age_value: Label = %AgeValue
@onready var race_value: Label = %RaceValue
@onready var gender_value: Label = %GenderValue
@onready var dominant_emotion_1: ProgressBar = %DominantEmotion1
@onready var dominant_emotion_2: ProgressBar = %DominantEmotion2
@onready var dominant_emotion_3: ProgressBar = %DominantEmotion3
@onready var dominant_emotion_4: ProgressBar = %DominantEmotion4
@onready var emotion_label_1: Label = %EmotionLabel1
@onready var emotion_label_2: Label = %EmotionLabel2
@onready var emotion_label_3: Label = %EmotionLabel3
@onready var emotion_label_4: Label = %EmotionLabel4

# We declared the root direction and the sub-directions that'll call the different functions
var url = 'http://127.0.0.1:5000/'
var api_functions = ['analyze','verify']

# This function is connected to the button up event of the LoadImageButton
func _on_load_image_button_up() -> void:
	print('Loading image')
	%FileDialog.popup()

# The button shows a file-system popup, when a file is selected, this function is called
func _on_file_dialog_file_selected(path: String) -> void:
	#Setting the image texture
	var image = Image.new()
	image.load(path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	%Image.texture = image_texture
	
	#Making the API call. It needs to treat the image as a file to make the proper transformation, that's why it's separete from the other code
	var file = FileAccess.open(path, FileAccess.READ)
	var base_64_data = Marshalls.raw_to_base64(file.get_buffer(file.get_length()))
	var body = JSON.new().stringify({
		"img_path": str('data:image/jpeg;base64,',base_64_data),
		"actions": ["age", "gender", "emotion", "race"]
		})
	var headers: PackedStringArray = ['Content-type:application/json']
	http_request.request(url+api_functions[0], headers, HTTPClient.METHOD_POST, body)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# We get the JSON response and parse it
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	print(response['results'][0])

	# We set the values to the labels
	age_value.text = str(response['results'][0]['age'])
	gender_value.text = str(response['results'][0]['dominant_gender'])
	race_value.text = str(response['results'][0]['dominant_race'])

	# We sort the emotions by percentage and set them to their respective progress bars
	var emotions: Dictionary = response['results'][0]['emotion']
	var keys = emotions.keys()
	# Sort keys in descending order of values.
	keys.sort_custom(func(x: String, y: String) -> bool: return emotions[x] > emotions[y])
	var emotion_value_pairs: Array = []
	for k: String in keys:
		emotion_value_pairs.append([k,emotions[k]])
	print('Emotion value pairs: ',emotion_value_pairs)
	# Set the values to the progress bars and labels
	dominant_emotion_1.value = emotion_value_pairs[0][1]
	emotion_label_1.text = emotion_value_pairs[0][0]
	dominant_emotion_2.value = emotion_value_pairs[1][1]
	emotion_label_2.text = emotion_value_pairs[1][0]
	dominant_emotion_3.value = emotion_value_pairs[2][1]
	emotion_label_3.text = emotion_value_pairs[2][0]
	dominant_emotion_4.value = emotion_value_pairs[3][1]
	emotion_label_4.text = emotion_value_pairs[3][0]
