extends Node2D

signal hit_player(bullet, player)

var direction = Vector2.ZERO
var speed = 0

func initialize(direction, speed):
	self.direction = direction
	self.speed = speed

func despawn():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, .45)
	
	yield(tween, 'finished')
	queue_free()

func _process(delta):
	position += direction * speed * delta

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("hit_player", self, body)
