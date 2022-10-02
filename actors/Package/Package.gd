extends Node2D

signal can_pickup(deliverable)
signal pickup(deliverable)

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var area = $Area2D

var texture

var picked_up = false
var delivered = false
var player

func _ready():
	animation_player.play("idle")
	sprite.texture = texture
	
	scale = Vector2.ZERO
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, .45)

func _process(delta):
	if not picked_up or player == null or delivered:
		return
	
	position = player.position + Vector2(0, -4)

func set_texture(texture):
	self.texture = texture

func deliver():
	if delivered:
		return
	
	delivered = true
	animation_player.play("pickup")

func can_pickup():
	emit_signal("can_pickup", self)

func pickup():
	if picked_up:
		return
	
	picked_up = true
	emit_signal("pickup", self)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		player = body
		can_pickup()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "pickup":
		queue_free()
