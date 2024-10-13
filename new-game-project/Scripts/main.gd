extends Control

# TODO: camera stream https://forum.godotengine.org/t/decode-an-image-sent-over-udp-from-python-opencv-to-godot-for-texture-data-use/3531/2

# Exporting variables makes them visible on the editor when the node is selected
@export var webcam_update_rate: float = 2.5
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
# Server that connects to the python script recording the webcam video
var server: UDPServer
var using_webcam: bool = false
var time: float = 0.0

func _ready() -> void:
	age_value.text = '?'
	gender_value.text = '?'
	race_value.text = '?'
	emotion_label_1.text = '?'
	emotion_label_2.text = '?'
	emotion_label_3.text = '?'
	emotion_label_4.text = '?'

# This function is called when each frame is drawn, useful for making anything move, in our case the progress bars
func _process(delta: float) -> void:
	if using_webcam:
		server.poll()
		if server.is_connection_available():
			
			var peer = server.take_connection()
			var frame_data = peer.get_packet()
			var image = _decode_image(frame_data)
			time += delta
			if time >= webcam_update_rate:
				time = 0.0
				send_http_deepface_request(image, api_functions[0])
			%Image.texture = ImageTexture.create_from_image(image)

	dominant_emotion_1.get("theme_override_styles/fill").bg_color = progress_bar_gradient.sample(dominant_emotion_1.value/100)
	dominant_emotion_2.get("theme_override_styles/fill").bg_color = progress_bar_gradient.sample(dominant_emotion_2.value/100)
	dominant_emotion_3.get("theme_override_styles/fill").bg_color = progress_bar_gradient.sample(dominant_emotion_3.value/100)
	dominant_emotion_4.get("theme_override_styles/fill").bg_color = progress_bar_gradient.sample(dominant_emotion_4.value/100)


# This function is connected to the button up event of the LoadImageButton
func _on_load_image_button_up() -> void:
	using_webcam = false
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
	send_http_deepface_request(image, api_functions[0])


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		printerr('HTTP Error ',response_code)
		if response_code == 400:
			printerr('Probably couldnt detect a face, try a different pose or better lighting')
		return
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
		emotion_value_pairs,
		!using_webcam
		)

func send_http_deepface_request(image: Image, function_name: String) -> void:
	print('Sending request with image: ',image,' , function_name: ',function_name)
	var base_64_data = Marshalls.raw_to_base64(image.save_jpg_to_buffer())
	var body = JSON.new().stringify({
		"img_path": str('data:image/jpeg;base64,',base_64_data),
		"actions": ["age", "gender", "emotion", "race"],
		"detector_backend": "opencv"
		})
	var headers: PackedStringArray = ['Content-type:application/json']
	http_request.request(url+function_name, headers, HTTPClient.METHOD_POST, body)

func set_animate_labels(age: String, gender: String, race: String, emotion_value_pairs: Array, animate_labels: bool) -> void:
	var tween = create_tween()

	var visible_ratio_value = 0
	if !animate_labels:
		visible_ratio_value = 1

	# Setting the values that'll later be animated
	age_value.text = age
	age_value.visible_ratio = visible_ratio_value
	gender_value.text = gender
	gender_value.visible_ratio = visible_ratio_value
	race_value.text = race
	race_value.visible_ratio = visible_ratio_value
	emotion_label_1.text = emotion_value_pairs[0][0]
	emotion_label_1.visible_ratio = visible_ratio_value
	emotion_label_2.text = emotion_value_pairs[1][0]
	emotion_label_2.visible_ratio = visible_ratio_value
	emotion_label_3.text = emotion_value_pairs[2][0]
	emotion_label_3.visible_ratio = visible_ratio_value
	emotion_label_4.text = emotion_value_pairs[3][0]
	emotion_label_4.visible_ratio = visible_ratio_value

	# Tweening different properties of the UI. Tweening is a way of animating through code. Tweens will wait for the previous tween to have finished to start executing, unless parallel() is specified.
	if animate_labels:
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


func _on_webcam_button_up() -> void:
	if !using_webcam:
		using_webcam = true
		server = UDPServer.new()
		server.listen(4242)
	else:
		using_webcam = false

func _decode_image(frame_data: PackedByteArray) -> Image:
	var image = Image.new()
	image.load_jpg_from_buffer(frame_data)
	return image
