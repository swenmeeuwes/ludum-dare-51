extends Node2D

signal can_deliver(delivery_target)

onready var sprite = $Sprite
onready var animation_player = $AnimationPlayer
onready var area = $Area2D
onready var warning_balloon = $WarningBalloon
onready var happy_balloon = $HappyBalloon

var texture

var delivered = false

func _ready():
	animation_player.play("idle")
	
	sprite.texture = texture
	
	warning_balloon.scale = Vector2.ZERO
	happy_balloon.scale = Vector2.ZERO
	
	scale = Vector2.ZERO
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, .45)

func set_texture(texture):
	self.texture = texture

func deliver():
	if delivered:
		return
	
	delivered = true
	show_completed()

func show_warning():
	if delivered:
		return
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(warning_balloon, "scale", Vector2.ONE, .45)

func show_completed():
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(happy_balloon, "scale", Vector2.ONE, .45)

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("can_deliver", self)
