extends Node

static var user_name: String = 'Unai'
static var first_time: bool = false
var server: UDPServer
var chosen_image: Image
var api_functions = ['analyze','verify']
var url = 'http://127.0.0.1:5000/'


func _ready() -> void:
	server = UDPServer.new()
	server.listen(4242)
	if first_time:
		%RichTextLabel.text = '[center]Hi [color=#d355b6]'+user_name+'[/color]! Lets take a [color=#d355b6]photo[/color]![/center]'
	else:
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
	send_http_deepface_request(chosen_image, api_functions[0])

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
