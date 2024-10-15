extends Control
var database : SQLite

func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()

func _on_add_user_button_down() -> void:
	var table = {
		"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true},
		"name": {"data_type": "text", "unique": true, "not_null": true},
		"picture": {"data_type": "BLOB", "not_null": true}
	}
	database.create_table("users", table)
	var data = {
		"name": $Name.text
	}
	database.insert_row("users", data)
	
	pass # Replace with function body.


func _on_see_content_button_down() -> void:
	print(database.select_rows("users", "", ["*"]))
	pass # Replace with function body.
