extends Control
var database : SQLite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	#var calendar_scene = preload("res://calendar.tscn")  # Cambia la ruta a la correcta
	get_tree().change_scene_to_file("res://calendar.tscn")


func _on_add_user_button_down() -> void:
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
	var data = {
		"user_id": $user.text,
		"day": $day.text,
		"month": $month.text,
		"year": $year.text,
		"emotion": $emotion.text
	}
	database.insert_row("day_emotions", data)
	
	pass # Replace with function body.


func _on_see_content_button_down() -> void:
	print(database.select_rows("day_emotions", "", ["*"]))
	pass # Replace with function body.


func _on_delete_user_button_down() -> void:
	database.drop_table("day_emotions")
