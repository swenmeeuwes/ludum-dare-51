extends KinematicBody2D

signal kill_player(enemy, player)

var movement_speed = 16
var player

func _ready():
	scale = Vector2.ZERO
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, .45)

func initialize(player, movement_speed):
	self.player = player
	self.movement_speed = movement_speed

func _process(delta):
	if player == null:
		return
	
	var direction_to_player = position.direction_to(player.position)
	move_and_collide(direction_to_player * movement_speed * delta)

func despawn():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ZERO, .45)
	tween.connect("finished", self, "_destroy")

func _destroy():
	queue_free()

func _on_KillPlayerArea2D_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("kill_player", self, body)
