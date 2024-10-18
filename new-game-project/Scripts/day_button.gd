extends Button
class_name DayButton

var year: int
var month: int
var day: int
var user_id: int

signal day_selected(year: int, month: int, day: int, image: Image)

func recived_signal_down() -> void:
	print(year,month,day)
	var where_clause = "user_id = '%s' AND day = '%s' AND month = '%s' AND year = '%s'" %[user_id, day, month, year]
	var result = SqlDatabase.database.select_rows("day_emotions", where_clause, ["*"])
	print(result)
	if result.size() == 0:
		day_selected.emit(year, month, day, null)
	else:
		print('there should be iamge')
		var image := Image.new()
		image.load_jpg_from_buffer(Marshalls.base64_to_raw((result[0]['picture'])))
		day_selected.emit(year, month, day, image)
