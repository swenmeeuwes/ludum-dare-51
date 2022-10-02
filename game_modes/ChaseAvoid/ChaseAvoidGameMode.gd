extends GameMode

var chasing_enemy_prefab = preload("res://actors/ChasingEnemy/ChasingEnemy.tscn")

var enemy_size = Vector2(16, 16)

var max_enemy_movement_speed = 128
var enemy_movement_speed = 128

var enemies = []

func _init():
	announcement = "Aliens?!"
	announcement_audio_stream = preload("res://sounds/aliens.ogg")
	
	enemy_movement_speed = min(max_enemy_movement_speed, 32 + 8 * difficulty_level)

func start():
	var enemies_to_spawn = min(20, 3 + floor(difficulty_level * 2))
	for i in range(0, enemies_to_spawn):
		_spawn_enemy()

func end():
	for enemy in enemies:
		_despawn_enemy(enemy)

func _spawn_enemy():
	var enemy = chasing_enemy_prefab.instance()
	enemy.initialize(player, enemy_movement_speed)
	enemy.position = _get_random_location()
	
	_register_enemy(enemy)
	
	add_child(enemy)

func _despawn_enemy(enemy):
	enemy.despawn()

func _get_random_location():
	var min_distance_from_player = player.movement_speed * .5 + enemy_movement_speed
	var x = 0
	var y = 0
	
	for i in range(0, 100):
		x = rand_range(enemy_size.x, screen_size.x - enemy_size.x)
		y = rand_range(enemy_size.y, screen_size.y - enemy_size.y)
		
		if Vector2(x, y).distance_to(player.position) > min_distance_from_player:
			break
	
	return Vector2(x, y)

func _register_enemy(enemy):
	enemy.connect("kill_player", self, "_on_Enemy_kill_player")
	enemies.append(enemy)

func _deregister_enemy(enemy):
	enemy.disconnect("kill_player", self, "_on_Enemy_kill_player")
	var enemy_index = enemies.find(enemy)
	enemies.remove(enemy_index)

func _on_Enemy_kill_player(enemy, player):
	lose()
