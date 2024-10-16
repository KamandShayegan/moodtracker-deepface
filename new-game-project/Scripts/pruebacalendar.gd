extends Node
class_name Calendar

@export var min_day_size := Vector2(75,75)
static var user_name: String
var current_year: int
var current_month: int
var first_day_of_week: int
var last_day_of_week: int
var current_day: int
var day_of_the_week
var emotions = ["fear", "happy", "disgust", "sad", "", "angry", "surprise", "happy", "fear", "", "sad", "disgust", "surprise", "angry", "sad", "surprise", "happy", "fear", "", "disgust", "angry", "happy", "surprise", "sad", "fear", "", "angry", "disgust", "happy", "surprise", "fear"]
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
	print(current_date)

	current_year = current_date.year
	for child in %GridContainer.get_children():
		if child is PanelContainer:
			child.get("theme_override_styles/panel").bg_color = Color("ffff0000")

	self.current_month = current_date.month
	self.current_day = current_date.day
	self.day_of_the_week = current_date.weekday
	#var month_label = get_node("month")
	#var year_label = get_node("year")
	draw_calendar(current_year, current_month, current_day, day_of_the_week, emotions)

func clear_and_populate_calendar() -> void:
	for child in %GridContainer.get_children():
		%GridContainer.remove_child(child)
		child.queue_free()
	
	for i in range(42):
		var label := Label.new()
		label.text = str(i)
		var vbox := VBoxContainer.new()
		vbox.add_child(label)
		var panel_container = PanelContainer.new()
		panel_container.add_child(vbox)
		panel_container.set("theme_override_styles/panel", StyleBoxFlat.new())
		panel_container.get("theme_override_styles/panel").bg_color = Color("ff0000ff")
		%GridContainer.add_child(panel_container)
	print(get_tree_string())

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

func draw_calendar(year: int, month: int, day: int,  week_day: int, emotions: Array):
	%month_label.text = months[current_month - 1]
	%year_label.text = str(current_year)
	for child in %GridContainer.get_children():
		if child is PanelContainer:
			child.get("theme_override_styles/panel").bg_color = Color("ffff0000")
			for ch in child.get_children():
				for c in ch.get_children():
					if c is Label:
						c.text = ""
	var days_in_month = get_days_in_month(year, month)
	
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
				day_label.text = str(day_count) # Establece el texto del Label

				day_count += 1  # Incrementar el contador de días
				rect_number +=1
	self.last_day_of_week = rect_number -1
# ... Resto del código ...

var last_week_day: int
var last_day: int
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
		draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day, self.emotions)
	else:
		self.current_day = get_days_in_month(self.current_year, self.current_month -1) 
		self.current_month -= 1
		self.day_of_the_week = self.last_week_day
		draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day, self.emotions)

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
		draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day, self.emotions)
	else:
		self.current_day = 1
		self.current_month += 1
		self.day_of_the_week = self.last_week_day
		draw_calendar(self.current_year, self.current_month, self.current_day, self.last_week_day, self.emotions)
