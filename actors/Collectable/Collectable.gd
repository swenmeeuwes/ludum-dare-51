extends Node2D

signal pick_up(collectable)

var pickup_sounds = [
	preload("res://sounds/pickup_1.wav"),
	preload("res://sounds/pickup_2.wav"),
	preload("res://sounds/pickup_3.wav"),
	preload("res://sounds/pickup_4.wav"),
	preload("res://sounds/pickup_5.wav"),
	preload("res://sounds/pickup_6.wav"),
]

onready var animation_player = $AnimationPlayer
onready var area = $Area2D
onready var sprite = $Sprite
onready var collection_particles = $CollectionParticles
onready var pickup_audio_stream_player = $PickupAudioStreamPlayer2D

var can_be_collected = false;
var themed_texture

func _ready():
	area.monitoring = false
	animation_player.play("spawn")
	
	sprite.texture = themed_texture

func set_texture(texture):
	themed_texture = texture
	
	if sprite != null:
		sprite.texture = themed_texture

func start():
	can_be_collected = true
	area.set_deferred("monitoring", true)
	animation_player.play("idle")

func pick_up():
	can_be_collected = false
	area.set_deferred("monitoring", false)
	animation_player.play("pickup")
	
	pickup_audio_stream_player.stream = pickup_sounds[randi() % pickup_sounds.size()]
	pickup_audio_stream_player.play()
	
	emit_signal("pick_up", self)

func despawn():
	animation_player.play("pickup") # TODO: other animation

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		collection_particles.emitting = true
		pick_up()
		pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "spawn":
		start()
	if anim_name == "pickup":
		queue_free()
