extends GameMode

var protectable_threat_prefab = preload("res://actors/ProtectableThreat/ProtectableThreat.tscn")

onready var protectable = $Protectable
onready var spawn_threat_timer = $SpawnThreatTimer

var meteor_themed_sprites = [
	preload("res://assets/earth.png"), # 0 = protectable
	preload("res://assets/meteor_1.png"),
	preload("res://assets/meteor_2.png"),
	preload("res://assets/meteor_3.png"),
]

var pizza_themed_sprites = [
	preload("res://assets/pizza_globe.png"), # 0 = protectable
	preload("res://assets/fork_1.png"),
]

var current_theme

var threat_size = Vector2(16, 16)
var circle_radius = 250

var max_enemy_movement_speed = 32

var threats = []

func _init():
	themes = [
		GameModeTheme.new(meteor_themed_sprites, "Meteorites?!", preload("res://sounds/meteorites.ogg")),
		GameModeTheme.new(pizza_themed_sprites, "Pizza party", preload("res://sounds/pizza_party.ogg")),
	]
	
	current_theme = get_theme()
	
	announcement = current_theme.themed_announcement
	announcement_audio_stream = current_theme.themed_announcement_audio

func _ready():
	spawn_threat_timer.wait_time = 1
	spawn_threat_timer.one_shot = false
	spawn_threat_timer.start()
	
	protectable.set_texture(current_theme.themed_sprites[0])

func start():
	_spawn_threat()

func end():
#	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
#	tween.tween_property(protectable, "scale", Vector2.ZERO, .45)
	
	for threat in threats:
		_despawn_threat(threat)

func _spawn_threat():
	var threat = protectable_threat_prefab.instance()
	var movement_speed = min(max_enemy_movement_speed, 16 + 2 * difficulty_level)
	threat.initialize(protectable, movement_speed)
	threat.position = _get_random_location()
	
	var threat_texture = current_theme.themed_sprites[1 + randi() % (current_theme.themed_sprites.size() - 1)]
	threat.set_texture(threat_texture)
	
	_register_threat(threat)
	
	add_child(threat)

func _despawn_threat(threat):
	_deregister_threat(threat)
	threat.despawn()

func _get_random_location():
	var random_radian = PI * (randf() * 2)
	
	var x = protectable.position.x + circle_radius * cos(random_radian)
	var y = protectable.position.y + circle_radius * sin(random_radian)
	
	return Vector2(x, y)

func _register_threat(threat):
	threat.connect("kill", self, "_on_ProtectableThreat_kill")
	threats.append(threat)

func _deregister_threat(threat):
	threat.disconnect("kill", self, "_on_ProtectableThreat_kill")
	var threat_index = threats.find(threat)
	threats.remove(threat_index)

func _on_Protectable_threat_entered(body):
	lose()

func _on_SpawnThreatTimer_timeout():
	_spawn_threat()

func _on_ProtectableThreat_kill(threat, killer):
	_deregister_threat(threat)
