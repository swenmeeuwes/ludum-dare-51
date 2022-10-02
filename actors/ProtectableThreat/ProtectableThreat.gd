extends KinematicBody2D

signal kill(threat, killer)

onready var collision_shape = $CollisionShape2D
onready var sprite = $Sprite
onready var death_audio_stream_player = $DeathAudioStreamPlayer

var death_audio = [
	preload("res://sounds/explosion_1.wav"),
	preload("res://sounds/explosion_2.wav"),
]

var warning_distance = 128
var movement_speed = 32
var target
var themed_texture

var active = true
var is_near_protectable = false

func _ready():
	sprite.texture = themed_texture
	
	scale = Vector2.ZERO
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, .45)

func initialize(target, movement_speed):
	self.target = target
	self.movement_speed = movement_speed

func set_texture(texture):
	themed_texture = texture

func _process(delta):
	if target == null or not active:
		return
	
	var direction_to_target = position.direction_to(target.position)
	move_and_collide(direction_to_target * movement_speed * delta)
	
	var distance_to_target = position.distance_to(target.position)
	if not is_near_protectable and distance_to_target < warning_distance:
		is_near_protectable = true
		_show_warning()
	
	
	look_at(target.position)

func despawn():
	if not active:
		return
	
	active = false
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, .45)
	tween.connect("finished", self, "_destroy")

func _destroy():
	queue_free()

func _show_warning():
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_loops(-1)
	tween.tween_property(self, "scale", Vector2.ONE * 1.2, .45)
	tween.tween_property(self, "scale", Vector2.ONE, .45)

func _on_KillArea2D_body_entered(body):
	if body.is_in_group("player"):
		collision_shape.set_deferred("disabled", true)
		emit_signal("kill", self, body)
		
		death_audio_stream_player.stream = death_audio[randi() % death_audio.size()]
		death_audio_stream_player.play()
		
		despawn()
