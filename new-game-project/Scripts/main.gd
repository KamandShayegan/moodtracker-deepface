extends Control

# TODO: camera stream https://forum.godotengine.org/t/decode-an-image-sent-over-udp-from-python-opencv-to-godot-for-texture-data-use/3531/2

# Exporting variables makes them visible on the editor when the node is selected
@export var progress_bar_gradient: Gradient

# Onready vars load nodes at the very beginning and make sure they are available at any time
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

func _ready() -> void:
	age_value.text = '?'
	gender_value.text = '?'
	race_value.text = '?'
	emotion_label_1.text = '?'
	emotion_label_2.text = '?'
	emotion_label_3.text = '?'
	emotion_label_4.text = '?'

# This function is called when each frame is drawn, useful for making anything move, in our case the progress bars
func _physics_process(delta: float) -> void:
	dominant_emotion_1.get("theme_override_styles/fill").bg_color = progress_bar_gradient.sample(dominant_emotion_1.value/100)
	dominant_emotion_2.get("theme_override_styles/fill").bg_color = progress_bar_gradient.sample(dominant_emotion_2.value/100)
	dominant_emotion_3.get("theme_override_styles/fill").bg_color = progress_bar_gradient.sample(dominant_emotion_3.value/100)
	dominant_emotion_4.get("theme_override_styles/fill").bg_color = progress_bar_gradient.sample(dominant_emotion_4.value/100)


# This function is connected to the button up event of the LoadImageButton
func _on_load_image_button_up() -> void:
	dominant_emotion_1.value = 0
	dominant_emotion_2.value = 0
	dominant_emotion_3.value = 0
	dominant_emotion_4.value = 0
	age_value.text = '?'
	gender_value.text = '?'
	race_value.text = '?'
	emotion_label_1.text = '?'
	emotion_label_2.text = '?'
	emotion_label_3.text = '?'
	emotion_label_4.text = '?'

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
	# Get the JSON response and parse it
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	# Sort the emotions by percentage and set them to their respective progress bars
	var emotions: Dictionary = response['results'][0]['emotion']
	var keys = emotions.keys()
	# Sort keys in descending order of values.
	keys.sort_custom(func(x: String, y: String) -> bool: return emotions[x] > emotions[y])
	var emotion_value_pairs: Array = []
	for k: String in keys:
		emotion_value_pairs.append([k,emotions[k]])

	# We set the values to the labels
	set_animate_labels(
		str(response['results'][0]['age']),
		str(response['results'][0]['dominant_gender']),
		str(response['results'][0]['dominant_race']), 
		emotion_value_pairs)


func set_animate_labels(age: String, gender: String, race: String, emotion_value_pairs: Array) -> void:
	var tween = create_tween()

	# Setting the values that'll later be animated
	age_value.text = age
	age_value.visible_ratio = 0
	gender_value.text = gender
	gender_value.visible_ratio = 0
	race_value.text = race
	race_value.visible_ratio = 0
	emotion_label_1.text = emotion_value_pairs[0][0]
	emotion_label_1.visible_ratio = 0
	emotion_label_2.text = emotion_value_pairs[1][0]
	emotion_label_2.visible_ratio = 0
	emotion_label_3.text = emotion_value_pairs[2][0]
	emotion_label_3.visible_ratio = 0
	emotion_label_4.text = emotion_value_pairs[3][0]
	emotion_label_4.visible_ratio = 0

	# Tweening different properties of the UI. Tweening is a way of animating through code. Tweens will wait for the previous tween to have finished to start executing, unless parallel() is specified.
	tween.tween_property(age_value, 'visible_ratio', 1, 0.35)
	tween.tween_property(gender_value, 'visible_ratio', 1, 0.45)
	tween.tween_property(race_value, 'visible_ratio', 1, 0.45)
	tween.tween_interval(0.4)
	tween.parallel().tween_property(dominant_emotion_1, 'value', emotion_value_pairs[0][1], 1.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(emotion_label_1, 'visible_ratio', 1, 0.7)
	tween.parallel().tween_property(dominant_emotion_2, 'value', emotion_value_pairs[1][1], 1.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(emotion_label_2, 'visible_ratio', 1, 0.7)
	tween.parallel().tween_property(dominant_emotion_3, 'value', emotion_value_pairs[2][1], 1.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(emotion_label_3, 'visible_ratio', 1, 0.7)
	tween.parallel().tween_property(dominant_emotion_4, 'value', emotion_value_pairs[3][1], 1.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_property(emotion_label_4, 'visible_ratio', 1, 0.7)
