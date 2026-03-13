extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 1200.0

@export var anim_idle: String = "RESET"
@export var anim_run: String = "run"
@export var anim_jump: String = "jump"

@export var sprite_faces_right: bool = true

# Настройки прыжка
@export var use_axis_up_for_jump: bool = false      # использовать ли стик вверх для прыжка
@export var allow_repeat_jump: bool = false         # разрешить ли многократные прыжки при удержании
@export var jump_repeat_delay: float = 0.3          # задержка между прыжками (если allow_repeat_jump = true)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var parts: Node2D = $parts

var current_anim: String = ""
var can_jump: bool = true
var jump_timer: float = 0.0

func _physics_process(delta):
	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta

	# Прыжок (обработка разных режимов)
	handle_jump(delta)

	# Горизонтальное движение
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	update_animation(direction)

func handle_jump(delta):
	# Проверяем, можно ли прыгать (на полу и прошла задержка для повтора)
	if not is_on_floor():
		can_jump = true  # сброс при приземлении
		jump_timer = 0.0
		return

	if allow_repeat_jump:
		# Режим многократных прыжков: обновляем таймер
		if jump_timer > 0:
			jump_timer -= delta

	# Определяем, хочет ли игрок прыгнуть
	var jump_pressed = false
	if use_axis_up_for_jump:
		# Ось вверх (обычно это отрицательное значение на оси Y левого стика)
		var axis_up = Input.get_axis("ui_up", "ui_down")  # или своё действие
		if axis_up > 0.5:  # наклон вверх
			jump_pressed = true
	else:
		# Используем стандартную кнопку
		if allow_repeat_jump:
			jump_pressed = Input.is_action_pressed("ui_accept")
		else:
			jump_pressed = Input.is_action_just_pressed("ui_accept")

	# Условие для прыжка
	var should_jump = false
	if allow_repeat_jump:
		# В режиме повтора нужна ещё проверка таймера
		if jump_pressed and can_jump and jump_timer <= 0:
			should_jump = true
			jump_timer = jump_repeat_delay
	else:
		# Однократный режим
		if jump_pressed and can_jump:
			should_jump = true
			can_jump = false  # блокируем до следующего приземления

	if should_jump:
		velocity.y = jump_velocity
		print("Прыжок!")

func update_animation(direction: float):
	var anim_to_play: String
	if is_on_floor():
		anim_to_play = anim_run if direction != 0 else anim_idle
	else:
		anim_to_play = anim_jump

	# Направление спрайта
	if direction != 0:
		if sprite_faces_right:
			parts.scale.x = sign(direction)
		else:
			parts.scale.x = -sign(direction)

	# Смена анимации
	if current_anim != anim_to_play:
		if animation_player.has_animation(anim_to_play):
			animation_player.play(anim_to_play)
			current_anim = anim_to_play
		else:
			print("Ошибка: анимация '", anim_to_play, "' не найдена")
			current_anim = ""
