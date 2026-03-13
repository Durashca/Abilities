extends Control

# Экспортируемая переменная для выбора следующей сцены в редакторе
@export var next_scene: PackedScene = preload("res://scenes/level_1.tscn")  # замените на путь к вашей сцене

func _ready():
	# Находим кнопки по имени
	var play_button = $VBoxContainer/ButtonPlay
	var exit_button =  $VBoxContainer/ButtonExit
	
	# Подключаем сигналы pressed
	play_button.pressed.connect(_on_play_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	# Переходим на следующую сцену, если она задана
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		print("Ошибка: следующая сцена не указана")

func _on_exit_pressed():
	# Выход из игры
	get_tree().quit()
