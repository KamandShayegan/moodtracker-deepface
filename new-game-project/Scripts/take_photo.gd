extends Node

var calendar_script = preload("res://Scripts/pruebacalendar.gd")
static var user_name: String = ''
static var first_time: bool = false
var server: UDPServer
var chosen_image: Image
var api_functions = ['analyze','verify']
var url = 'http://127.0.0.1:5000/'
var http_response

signal response_recieved


func _ready() -> void:
	server = UDPServer.new()
	server.listen(4242)
	if first_time:
		var regex = RegEx.new()
		regex.compile("[a-z]+")
		user_name = regex.search(user_name.to_lower()).get_string()
		user_name.capitalize()
	if first_time:
		%BackButton.previous_scene_path = "res://Scenes/fill_name.tscn"
		%RichTextLabel.text = '[center]Hi [color=#d355b6]'+user_name+'[/color]! Lets take a [color=#d355b6]photo[/color]![/center]'
	else:
		%BackButton.previous_scene_path = "res://Scenes/on_boarding.tscn"
		%RichTextLabel.text = "[center]Let's [color=#d355b6]identify[/color] you shall we?[/center]"

func _process(_delta: float) -> void:
	if %PhotoTimer.is_stopped():
		%Button.visible = true
		%TimeLeft.visible = false
	else:
		%Button.visible = false
		%TimeLeft.visible = true
		%TimeLeft.text = str(round(%PhotoTimer.time_left))
	
	if !chosen_image:
		%Button.text = 'Take a picture'
		%Next.visible = false
	else:
		%Button.text = 'Take another picture'
		%Next.visible = true

	server.poll()
	if server.is_connection_available() and (!chosen_image or !%PhotoTimer.is_stopped()):
		var peer = server.take_connection()
		var frame_data = peer.get_packet()
		var image = _decode_image(frame_data)
		if !%PhotoTimer.is_stopped():
			chosen_image = image
		%Image.texture = ImageTexture.create_from_image(image)

func _decode_image(frame_data: PackedByteArray) -> Image:
	var image = Image.new()
	image.load_jpg_from_buffer(frame_data)
	return image

func _on_photo_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(%Image, 'modulate', Color('3e3e3e'), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(%Image, 'modulate', Color('ffffff'), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func _on_button_button_up() -> void:
	chosen_image = null
	%PhotoTimer.start()


func _on_next_button_up() -> void:
	var existing_face = false
	var users: Array = SqlDatabase.get_users()
	var min_distance_user: Array = []
	%RichTextLabel.text = "[center]We're checking the [color=#d355b6]database[/color][/center]"
	
	for user: Dictionary in users:
		var image := Image.new()
		image.load_jpg_from_buffer(Marshalls.base64_to_raw((user['picture'])))
		%Image.texture = ImageTexture.create_from_image(chosen_image)
		send_verify_request(chosen_image, image)
		await Signal(self, 'response_recieved')
		existing_face = http_response['verified']
		print(http_response)
		if existing_face:
			if !min_distance_user:
				min_distance_user.append(http_response['distance'])
				min_distance_user.append(user['name'])
			elif min_distance_user[0] > http_response['distance']:
				min_distance_user[0] = http_response['distance']
				min_distance_user[1] = user['name']
	if min_distance_user != [] and first_time:
		%RichTextLabel.text = '[center]You are already in the [color=#d355b6]database[/color]![/center]'
	elif min_distance_user != []:
		calendar_script.user_name = min_distance_user[1]
		var current_user_id = SqlDatabase.get_user_id(min_distance_user[1])
		calendar_script.current_user = current_user_id
		SceneTransitions.change_scene("res://Scenes/calendar.tscn")
	elif min_distance_user == [] and first_time:
		SqlDatabase.add_user(user_name, chosen_image)
		var current_user_id = SqlDatabase.get_user_id(user_name)
		calendar_script.current_user = current_user_id
		calendar_script.user_name = user_name
		SceneTransitions.change_scene("res://Scenes/calendar.tscn")


func send_http_deepface_request(image: Image, function_name: String) -> void:
	print('Sending request with image: ',image,' , function_name: ',function_name)
	var base_64_data = Marshalls.raw_to_base64(image.save_jpg_to_buffer())
	var body = JSON.new().stringify({
		"img_path": str('data:image/jpeg;base64,',base_64_data),
		"actions": ["age", "gender", "emotion", "race"],
		"detector_backend": "opencv"
		})
	var headers: PackedStringArray = ['Content-type:application/json']
	%HTTPRequest.request(url+function_name, headers, HTTPClient.METHOD_POST, body)

func send_verify_request(image1: Image, image2: Image) -> void:
	var base_64_data1 = Marshalls.raw_to_base64(image1.save_jpg_to_buffer())
	var base_64_data2 = Marshalls.raw_to_base64(image2.save_jpg_to_buffer())
	var body = JSON.new().stringify({
		"img1_path": str('data:image/jpeg;base64,',base_64_data1),
		"img2_path": str('data:image/jpeg;base64,',base_64_data2),
		"model_name": "Facenet512",
		"detector_backend": "opencv",
		"distance_metric": "euclidean",
		"enforce_detection": "false"
		})
	var headers: PackedStringArray = ['Content-type:application/json']
	%HTTPRequest.request(url+'verify', headers, HTTPClient.METHOD_POST, body)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		printerr('HTTP Error ',response_code)
		if response_code == 400:
			%RichTextLabel.text = "[center]Seems like the photo wasn't good enough, let's try taking another one![/center]"
			chosen_image = null
			printerr('Probably couldnt detect a face, try a different pose or better lighting')
		return
	# Get the JSON response and parse it
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	# Sort the emotions by percentage and set them to their respective progress bars
	print(response)
	if response == null:
		%RichTextLabel.text = "[center]Seems like the photo wasn't good enough, let's try taking another one![/center]"
		chosen_image = null
		printerr('Probably couldnt detect a face, try a different pose or better lighting')
		return
	if response.has('verified'):
		http_response = response
		response_recieved.emit()
	elif response['results'][0]['emotion']:
		var emotions: Dictionary = response['results'][0]['emotion']
		var keys = emotions.keys()
		# Sort keys in descending order of values.
		keys.sort_custom(func(x: String, y: String) -> bool: return emotions[x] > emotions[y])
		var emotion_value_pairs: Array = []
		for k: String in keys:
			emotion_value_pairs.append([k,emotions[k]])
