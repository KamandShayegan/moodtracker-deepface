extends Node

static var user_name: String = 'Unai'
var server: UDPServer
var chosen_image: Image

func _ready() -> void:
	server = UDPServer.new()
	server.listen(4242)
	%RichTextLabel.text = '[center]Hi [color=#d355b6]'+user_name+'[/color]! Lets take a [color=#d355b6]photo[/color]![/center]'
	print(%RichTextLabel.text)

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
		%Button2.visible = false
	else:
		%Button.text = 'Take another picture'
		%Button2.visible = true

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
