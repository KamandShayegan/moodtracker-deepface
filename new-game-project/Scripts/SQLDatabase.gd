extends Node
var database : SQLite

func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	#database.delete_rows('users','*')
	#var image = Image.new()
	#image.load("res://Assets/Images/2024-10-13-033327.jpg")
	#add_user('Unai',image)
	#var table = {
		#"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		#"user_id": {"data_type": "text", "not_null": true},
		#"emotion": {"data_type": "text", "not_null": true},
		#"day": {"data_type": "text", "not_null": true},
		#"month": {"data_type": "text", "not_null": true},
		#"year": {"data_type": "text", "not_null": true},
		#"picture": {"data_type": "BLOB", "not_null": true}
	#}
	#database.create_table("day_emotions", table)
	#var unique_constraint_query = "CREATE UNIQUE INDEX IF NOT EXISTS unique_emotion ON day_emotions (user_id, day, month, year)"
	#database.query(unique_constraint_query)

func set_user_table() -> void:
	var table = {
		"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		"name": {"data_type": "text", "unique": true, "not_null": true},
		"picture": {"data_type": "BLOB", "not_null": true}
	}
	database.create_table("users", table)

func add_user(user_name: String, picture: Image) -> void:
	var regex = RegEx.new()
	regex.compile("[a-z]+")
	user_name = regex.search(user_name.to_lower()).get_string()
	var base_64_data = Marshalls.raw_to_base64(picture.save_jpg_to_buffer())
	var data = {
		"name": user_name,
		"picture": base_64_data
	}
	database.insert_row("users", data)

func get_user_id(user_name: String) -> int:
	var regex = RegEx.new()
	regex.compile("[a-z]+")
	user_name = regex.search(user_name.to_lower()).get_string()
	var response: Array = database.select_rows("users","name = '%s'"%[user_name],["*"])
	print(response)
	var id = response[0]['id']
	return int(id)

func get_users() -> Array:
	return database.select_rows("users", "", ["*"])
