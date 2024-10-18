extends Button
class_name DayButton

var year: int
var month: int
var day: int

signal day_selected(year: int, month: int, day: int)

func recived_signal_down() -> void:
	print(year,month,day)
	day_selected.emit(year, month, day)
