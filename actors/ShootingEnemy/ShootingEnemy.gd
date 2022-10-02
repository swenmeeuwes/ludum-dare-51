extends Node2D

signal player_hit

var bullet_prefab = preload("res://actors/Bullet/Bullet.tscn")

var shoot_audio = [
	preload("res://sounds/alien_1.wav"),
	preload("res://sounds/alien_2.wav"),
	preload("res://sounds/alien_3.wav"),
	preload("res://sounds/alien_4.wav"),
	preload("res://sounds/alien_5.wav"),
	preload("res://sounds/alien_6.wav"),
]

onready var shoot_timer = $ShootTimer
onready var shoot_audio_stream = $ShootAudioStreamPlayer2D

var bullets = []
var bullet_speed = 32
var shoot_interval_range = Vector2(1, 2)

func _ready():
	randomize()
	
	scale = Vector2.ZERO
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, .45)
	
	yield(tween, 'finished')
	
	shoot_timer.wait_time = .05
	shoot_timer.one_shot = true
	shoot_timer.start()

func initialize(bullet_speed, shoot_interval_range):
	self.bullet_speed = bullet_speed
	self.shoot_interval_range = shoot_interval_range

func _shoot_circle(amount):
	shoot_audio_stream.stream = shoot_audio[randi() % shoot_audio.size()]
	shoot_audio_stream.play()
	
	var radian_interval = (PI * 2.0) / amount
	for i in range(0, amount):
		var direction = _get_bullet_direction_for_radian(radian_interval * i)
		_spawn_bullet(direction, bullet_speed)

func _get_bullet_direction_for_radian(radian):
	var x = cos(radian)
	var y = sin(radian)
	
	return Vector2(x, y)

func _spawn_bullet(direction, speed):
	var bullet = bullet_prefab.instance()
	bullet.initialize(direction, speed)
	
	register_bullet(bullet)
	
	get_parent().add_child(bullet)
	bullet.position = position

func despawn():
	for bullet in bullets:
		deregister_bullet(bullet)
		bullet.despawn()

func register_bullet(bullet):
	bullet.connect("hit_player", self, "_on_Bullet_player_hit")
	bullets.append(bullet)

func deregister_bullet(bullet):
	bullet.disconnect("hit_player", self, "_on_Bullet_player_hit")
	
	var bullet_index = bullets.find(bullet)
	bullets.remove(bullet_index)

func _on_Bullet_player_hit(bullet, player):
	deregister_bullet(bullet)
	bullet.despawn()
	
	emit_signal("player_hit")

func _on_ShootTimer_timeout():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT).set_loops(3)
	tween.tween_property(self, "scale", Vector2.ONE * 1.1, .35)
	tween.tween_property(self, "scale", Vector2.ONE, .35)
	
	yield(tween, "finished")
	
	_shoot_circle(10)
	
	shoot_timer.wait_time = rand_range(shoot_interval_range.x, shoot_interval_range.y)
	shoot_timer.start()
