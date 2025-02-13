extends Node
class_name Calendar

@export var min_day_size := Vector2(75,75)
static var user_name: String
static var current_user: int
var current_year: int
var current_month: int
var first_day_of_week: int
var last_day_of_week: int
var current_day: int
var day_of_the_week
var database
var emotions = []
var last_week_day:int
var last_day: int
var button_year: int
var button_month: int
var button_day:int
var today:= false
@export var emotion_dict: Dictionary = {
	"sad": Color("4ba1ee"),
	"happy": Color("ebe195"),
	"angry": Color("ff0000df"),
	"surprise": Color("df0062e2"),
	"fear": Color("9f009fe8"),
	"disgust": Color("00ab00e2"),
	"neutral": Color("ffff0000")
}
var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

func _ready():
	var current_date = Time.get_datetime_dict_from_system()
	#self.database = SQLite.new()
	#self.database.path("res://data.db")
	#self.database.open_db()
	%RichTextLabel.text = "[center]Hello [color=#d355b6]"+user_name.capitalize()+"[/color]![/center]"
	current_year = current_date.year
	for child in %GridContainer.get_children():
		if child is PanelContainer:
			child.get("theme_override_styles/panel").bg_color = Color("ffff0000")

	self.current_month = current_date.month
	self.current_day = current_date.day
	self.day_of_the_week = current_date.weekday
	self.last_week_day = day_of_the_week
	#var month_label = get_node("month")
	#var year_label = get_node("year")
	%TakePicture.save_day.connect(Callable(self,'save_mood'))
	draw_calendar(current_year, current_month, current_day, day_of_the_week)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		%TakePicture.update_camera_panel(false)
		var tween = create_tween()
		tween.tween_property(%VBoxContainer,'modulate',Color('ffffffff'),0.3)

# Función para obtener el valor de la emoción
func get_emotion_value(emotion: String) -> Color:
	if emotion_dict.has(emotion):
		return emotion_dict[emotion]  # Devuelve el valor asociado
	else:
		return Color("a8a8a8")  # O cualquier valor para emociones no encontradas
# Función para verificar si un año es bisiesto
func is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

# Función para dibujar el calendario en un Grid
# Función para obtener el número de días en un mes
func get_days_in_month(year: int, month: int) -> int:
	var days_in_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if month == 2 and is_leap_year(year):  # Verifica si es febrero y año bisiesto
		return 29
	return days_in_month[month - 1]
	
# ... Código anterior ...

func draw_calendar(year: int, month: int, day: int,  week_day: int):
	%month_label.text = months[current_month - 1]
	%year_label.text = str(current_year)
	if current_month == 12:
		%previus.text = months[10]
		%next.text = months[0]
	elif current_month == 1:
		%previus.text = months[11]
		%next.text = months[1]
	else:
		%previus.text = months[current_month -2]
		%next.text = months[current_month]
	self.emotions = []
	var actual_date = Time.get_datetime_dict_from_system()
	for child in %GridContainer.get_children():
		if child is PanelContainer:
			child.get("theme_override_styles/panel").bg_color = Color("ffff0000")
			for ch in child.get_children():
				for c in ch.get_children():
					if c is DayButton:
						c.text = ""
						c.disabled = true
	var days_in_month = get_days_in_month(year, month)
	self.emotions = fill_emotions_month(days_in_month)
	var starting_day = day  # Suponiendo que sabes que el día 14 es lunes
	var first_day = 1 - day   # 1 = 1er día del mes
	var first_day_weekday = (week_day - 1 + first_day) % 7
	print(starting_day, first_day, first_day_weekday)
# Ajuste para asegurar que el resultado esté en el rango [1, 7]
	if first_day_weekday <= 0:
		first_day_weekday += 7
	self.first_day_of_week = first_day_weekday + 1
	print(self.first_day_of_week)
	# Usar un contador para los días
	var day_count = 1
	var rect_number = first_day_weekday +1
	while day_count >= 1 and day_count <= days_in_month:
				# Crear ColorRect para el día
# Construir el nombre del nodo
				var node_n = "PanelContainer" + str(rect_number)  
# Acceder al ColorRect usando get_node
				var color_panel = %GridContainer.get_node(node_n)
				color_panel.get("theme_override_styles/panel").bg_color = get_emotion_value(emotions[day_count - 1])
				var node_name = "PanelContainer" + str(rect_number) + "/VBoxContainer42/Label"  
				var day_label = %GridContainer.get_node(node_name)
				#day_label.set_script("res://Scripts/day_button.gd")
				day_label.year = current_year
				day_label.month = current_month
				day_label.day = day_count
				day_label.user_id = current_user
				day_label.disabled = false
				if current_year > actual_date.year:
					day_label.disabled = true
				elif current_year == actual_date.year:
					if current_month > actual_date.month :
						day_label.disabled = true
					elif current_month == actual_date.month: 
						if day_count > actual_date.day:
							day_label.disabled = true
				day_label.connect('button_down', Callable(day_label,'recived_signal_down'))
				day_label.day_selected.connect(Callable(self,'day_button_pressed'))
				day_label.text = str(day_count) # Establece el texto del Label

				day_count += 1  # Incrementar el contador de días
				rect_number +=1
	self.last_day_of_week = rect_number -1
# ... Resto del código ...

func _on_previus_button_down() -> void:
	if (self.first_day_of_week == 1):
		self.last_week_day = 7
	else:
		self.last_week_day = first_day_of_week - 1
		
	print("last month's last day was: ", self.last_week_day)
	if(self.current_month == 1):
		self.current_day = get_days_in_month(self.current_year - 1, 12)
		self.current_year -= 1
		self.current_month = 12
		self.day_of_the_week = self.last_week_day
		draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day)
	else:
		self.current_day = get_days_in_month(self.current_year, self.current_month -1) 
		self.current_month -= 1
		self.day_of_the_week = self.last_week_day
		draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day)

func _on_next_button_down() -> void:
	print(self.last_day_of_week)
	if (self.last_day_of_week == 7):
		self.last_week_day = 1
	else:
		self.last_week_day = self.last_day_of_week + 1
		
	print("next month's next day is: ", self.last_week_day)
	if(self.current_month == 12):
		self.current_day = 1
		self.current_year += 1
		self.current_month = 1
		self.day_of_the_week = self.last_week_day
		draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day)
	else:
		self.current_day = 1
		self.current_month += 1
		self.day_of_the_week = self.last_week_day
		draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day)

func fill_emotions_month(last_day:int) -> Array:
	var emotions_array = []
	var day_count = 1
	while day_count <= last_day:
		var where_clause = "user_id = '%s' AND day = %d AND month = %d AND year = %d" % [self.current_user, day_count, self.current_month, self.current_year]
		var result = SqlDatabase.database.select_rows("day_emotions", where_clause, ["*"])
		#print('Result: ',result)
		if result.size() == 0:
			emotions_array.append("")
		else:
			emotions_array.append(result[0]["emotion"])
		day_count +=1
	return emotions_array


func _on_take_picture_button_down() -> void:
	var actual_date = Time.get_datetime_dict_from_system()
	var where_clause = "user_id = '%s' AND day = '%s' AND month = '%s' AND year = '%s'" %[current_user, actual_date.day, actual_date.month, actual_date.year]
	var result = SqlDatabase.database.select_rows("day_emotions", where_clause, ["*"])
	print(result)
	if result.size() == 0:
		var tween = create_tween()
		tween.tween_property(%VBoxContainer,'modulate',Color('ffffff35'),0.3)
		self.today = true
		%TakePicture.todays_copy = today
		%TakePicture.update_camera_panel(true)
		%TakePicture.date = ''
	else:
		var tween = create_tween()
		tween.tween_property(%WarrniingLabel,'modulate',Color('ffffffff'),0.3)
		tween.tween_interval(1)
		tween.tween_property(%WarrniingLabel,'modulate',Color('ffffff00'), 0.6)
	
func day_button_pressed(year: int, month:int, day:int, image: Image) -> void:
	print("si")
	var tween = create_tween()
	tween.tween_property(%VBoxContainer,'modulate',Color('ffffff35'),0.3)
	self.today = false
	self.button_day= day
	self.button_month = month
	self.button_year = year
	if image != null:
		%TakePicture.recieved_image = image
	%TakePicture.date = str(day,'/',month,'/',year)
	%TakePicture.todays_copy = today
	%TakePicture.update_camera_panel(true)


func save_mood(image: Image, emotion: String) -> void:
	print('SIGNAL RECIEVED')
	var base_64_data = Marshalls.raw_to_base64(image.save_jpg_to_buffer())
	var current_date = Time.get_datetime_dict_from_system()
	var day_of = current_date.weekday
	var year
	var month
	var day
	if today: 
		year = current_date.year
		month = current_date.month
		day = current_date.day
	else:
		year = button_year
		month = button_month
		day = button_day
	var new_row: Dictionary = {
		'user_id': current_user,
		'emotion': emotion,
		'day': day,
		'month': month,
		'year': year,
		'picture': base_64_data
	}
	SqlDatabase.database.insert_row("day_emotions", new_row)
	draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day)
	var tween = create_tween()
	tween.tween_property(%VBoxContainer,'modulate',Color('ffffffff'),0.3)
	%TakePicture.update_camera_panel(false)
