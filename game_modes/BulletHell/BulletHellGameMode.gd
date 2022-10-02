extends GameMode

var shooting_enemy_prefab = preload("res://actors/ShootingEnemy/ShootingEnemy.tscn")

var enemy_size = Vector2(16, 16)

var enemies = []

func _init():
	announcement = "BULLET HELL"
	announcement_audio_stream = preload("res://sounds/bullet_hell.ogg")

func start():
	var enemies_to_spawn = 3 + difficulty_level
	for i in range(0, enemies_to_spawn):
		_spawn_enemy()

func end():
	for enemy in enemies:
		_despawn_enemy(enemy)

func _spawn_enemy():
	var enemy = shooting_enemy_prefab.instance()
	enemy.position = _get_random_location()
	
	var bullet_speed = min(96, 32 + difficulty_level * 4)
	
	var shoot_interval_min = min(.1, 1.5 - .1 * difficulty_level)
	var shoot_interval_max = min(.1, 3 - .2 * difficulty_level)
	var shoot_interval_range = Vector2(shoot_interval_min, shoot_interval_max)
	enemy.initialize(bullet_speed, shoot_interval_range)
	
	_register_enemy(enemy)
	
	add_child(enemy)

func _despawn_enemy(enemy):
	enemy.despawn()

func _get_random_location():
	var x = rand_range(enemy_size.x, screen_size.x - enemy_size.x)
	var y = rand_range(enemy_size.y, screen_size.y - enemy_size.y)
	
	return Vector2(x, y)

func _register_enemy(enemy):
	enemy.connect("player_hit", self, "_on_Enemy_player_hit")
	enemies.append(enemy)

func _deregister_enemy(enemy):
	enemy.disconnect("player_hit", self, "_on_Enemy_player_hit")
	var enemy_index = enemies.find(enemy)
	enemies.remove(enemy_index)

func _on_Enemy_player_hit():
	lose()
