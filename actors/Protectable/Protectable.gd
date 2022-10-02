extends Node2D

signal threat_entered(body)

var cloud_textures = [
	preload("res://assets/cloud_1.png"),
	preload("res://assets/cloud_2.png"),
	preload("res://assets/cloud_3.png"),
]

onready var clouds_container = $Clouds
onready var sprite = $Sprite

var cloud_rotation_speed = PI / 32
var active = true;

var themed_texture

func _ready():
	if themed_texture != null:
		sprite.texture = themed_texture
	
	_create_clouds()

func _process(delta):
	clouds_container.rotation += cloud_rotation_speed * delta
	
	for child in clouds_container.get_children():
		child.look_at(position)
		child.rotate(-PI * .5)

func _create_clouds():
	for i in range(0, 16):
		randomize()
		var sprite = Sprite.new()
		sprite.texture = cloud_textures[randi() % cloud_textures.size()]
		clouds_container.add_child(sprite)
		sprite.global_position.y -= 48 + 12 + randf() * 12
		clouds_container.rotation = PI * randf() * 2
		
		print(clouds_container.rotation)

func _on_Area2D_body_entered(body):
	if not active or not body.is_in_group("threat"):
		return
	
	active = false
	emit_signal("threat_entered", body)

func set_texture(texture):
	self.themed_texture = texture
	if sprite != null:
		sprite.texture = themed_texture
