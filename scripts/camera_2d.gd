extends Camera2D

@export var target: Node2D
@export var smoothing_speed: float = 5.0

func _ready():
	if not target:
		var players = get_tree().get_nodes_in_group("player")
		if players:
			target = players[0]
		else:
			print("Игрок не найден в группе 'player'")

func _process(delta):
	if target:
		global_position = global_position.lerp(target.global_position, smoothing_speed * delta)
