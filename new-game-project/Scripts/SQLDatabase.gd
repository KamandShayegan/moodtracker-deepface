extends Node
var database : SQLite

func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	var image = Image.new()
	image.load("res://Assets/Images/2024-10-12-220632.jpg")
	add_user('Unai',image)

func set_user_table() -> void:
	var table = {
		"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		"name": {"data_type": "text", "unique": true, "not_null": true},
		"picture": {"data_type": "BLOB", "not_null": true}
	}
	database.create_table("users", table)

func add_user(name: String, picture: Image) -> void:
	var base_64_data = Marshalls.raw_to_base64(picture.save_jpg_to_buffer())
	var data = {
		"name": 'Unai',
		"picture": base_64_data
	}
	database.insert_row("users", data)


func get_users() -> Array:
	return database.select_rows("users", "", ["*"])
