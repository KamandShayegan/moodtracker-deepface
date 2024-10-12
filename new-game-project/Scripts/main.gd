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

var de1_target_value: float = 0
var de2_target_value: float = 0
var de3_target_value: float = 0
var de4_target_value: float = 0

# This function is called when each frame is drawn, useful for making anything move, in our case the progress bars
func _process(delta: float) -> void:
	dominant_emotion_1.value = lerp(dominant_emotion_1.value, de1_target_value, delta * 2.2)
	dominant_emotion_2.value = lerp(dominant_emotion_2.value, de2_target_value, delta * 2.2)
	dominant_emotion_3.value = lerp(dominant_emotion_3.value, de3_target_value, delta * 2.2)
	dominant_emotion_4.value = lerp(dominant_emotion_4.value, de4_target_value, delta * 2.2)

# This function is connected to the button up event of the LoadImageButton
func _on_load_image_button_up() -> void:
	de1_target_value = 0
	de2_target_value = 0
	de3_target_value = 0
	de4_target_value = 0
	%FileDialog.popup()

# The button shows a file-system popup, when a file is selected, this function is called
func _on_file_dialog_file_selected(path: String) -> void:
	#Setting the image texture
	var image = Image.new()
	image.load(path)

	# Image resizing for quicker api calls
	var resize_factor = min((512.0 / float(image.get_height())), 1)
	image.resize(image.get_width()*resize_factor, image.get_height()*resize_factor)

	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	%Image.texture = image_texture
	
	#Making the API call. It needs to treat the image as a file to make the proper transformation, that's why it's separete from the other code
	var file = FileAccess.open(path, FileAccess.READ)
	var base_64_data = Marshalls.raw_to_base64(image.save_jpg_to_buffer())
	var body = JSON.new().stringify({
		"img_path": str('data:image/jpeg;base64,',base_64_data),
		"actions": ["age", "gender", "emotion", "race"],
		"detector_backend": "opencv"
		})
	var headers: PackedStringArray = ['Content-type:application/json']
	http_request.request(url+api_functions[0], headers, HTTPClient.METHOD_POST, body)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# We get the JSON response and parse it
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

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
	# Set the values to the progress bars and labels
	de1_target_value = emotion_value_pairs[0][1]
	emotion_label_1.text = emotion_value_pairs[0][0]
	de2_target_value = emotion_value_pairs[1][1]
	emotion_label_2.text = emotion_value_pairs[1][0]
	de3_target_value = emotion_value_pairs[2][1]
	emotion_label_3.text = emotion_value_pairs[2][0]
	de4_target_value = emotion_value_pairs[3][1]
	emotion_label_4.text = emotion_value_pairs[3][0]
