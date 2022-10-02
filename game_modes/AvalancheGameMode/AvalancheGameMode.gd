extends GameMode

var warning_icon_prefab = preload("res://actors/WarningIcon/WarningIcon.tscn")
var boulder_prefab = preload("res://actors/FallingBoulder/FallingBoulder.tscn")

var boulder_themed_sprites = [
	preload("res://assets/boulder_1.png")
]

var chocolate_themed_sprites = [
	preload("res://assets/chocolate_bar_1.png"),
	preload("res://assets/chocolate_bar_2.png"),
	preload("res://assets/chocolate_bar_3.png")
]

onready var spawn_timer = $SpawnTimer

var enemy_size = Vector2(16, 16)

var max_enemy_movement_speed = 160
var enemy_movement_speed = 64

var enemies = []

var theme: GameModeTheme

func _init():
	themes = [
		GameModeTheme.new(boulder_themed_sprites, "Avalanche", preload("res://sounds/avalanche.ogg")),
		GameModeTheme.new(chocolate_themed_sprites, "Chocolate Rain", preload("res://sounds/chocolate_rain.ogg")),
	]
	
	theme = get_theme()
	
	announcement = theme.themed_announcement
	announcement_audio_stream = theme.themed_announcement_audio
	
	enemy_movement_speed = min(max_enemy_movement_speed, 48 + 16 * difficulty_level)

func start():
	spawn_timer.wait_time = max(.8, 3.0 - .5 * difficulty_level)
	spawn_timer.start()
	
	_spawn_round_of_boulders()

func end():
	for enemy in enemies:
		_despawn_enemy(enemy)

func _spawn_enemy():
	var enemy_position = _get_random_location()
	
	var warning = warning_icon_prefab.instance()
	warning.call_deferred("show_warning", 1.0)
	warning.position = Vector2(enemy_position.x, 16)
	add_child(warning)
	
	var enemy_tex = theme.themed_sprites[randi() % theme.themed_sprites.size()]
	var enemy = boulder_prefab.instance()
	enemy.set_texture(enemy_tex)
	enemy.initialize(enemy_movement_speed, 1.0)
	enemy.position = enemy_position
	
	_register_enemy(enemy)
	
	add_child(enemy)

func _despawn_enemy(enemy):
	enemy.despawn()

func _get_random_location():
	var x = randf() * screen_size.x
	var y = -32
	
	return Vector2(x, y)

func _register_enemy(enemy):
	enemy.connect("kill_player", self, "_on_Enemy_kill_player")
	enemies.append(enemy)

func _deregister_enemy(enemy):
	enemy.disconnect("kill_player", self, "_on_Enemy_kill_player")
	var enemy_index = enemies.find(enemy)
	enemies.remove(enemy_index)

func _spawn_round_of_boulders():
	var enemies_to_spawn = min(20, 6 + floor(difficulty_level * 3))
	for i in range(0, enemies_to_spawn):
		_spawn_enemy()

func _on_Enemy_kill_player(enemy, player):
	lose()

func _on_SpawnTimer_timeout():
	_spawn_round_of_boulders()
