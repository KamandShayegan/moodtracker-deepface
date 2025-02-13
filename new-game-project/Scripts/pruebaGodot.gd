extends Control
var database : SQLite

func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	var table = {
		"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		"user_id": {"data_type": "text", "not_null": true},
		"emotion": {"data_type": "text", "not_null": true},
		"day": {"data_type": "text", "not_null": true},
		"month": {"data_type": "text", "not_null": true},
		"year": {"data_type": "text", "not_null": true},
		"picture": {"data_type": "BLOB", "not_null": true}
	}
	database.create_table("day_emotions", table)
	var unique_constraint_query = "CREATE UNIQUE INDEX IF NOT EXISTS unique_emotion ON day_emotions (user_id, day, month, year)"
	database.query(unique_constraint_query)

func _on_add_user_button_down() -> void:
	var table = {
		"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		"name": {"data_type": "text", "unique": true, "not_null": true},
		"picture": {"data_type": "BLOB", "not_null": true}
	}
	database.create_table("users_pictures", table)
	var data = {
		"name": $Name.text,
		"picture": 'pasfjoaihfSJAFOIHAOPFhaSFOniaLKsfnñalKsfn'
	}
	database.insert_row("users_pictures", data)
	
	pass # Replace with function body.


func _on_see_content_button_down() -> void:
	print(database.select_rows("users", "", ["*"]))
	pass # Replace with function body.
