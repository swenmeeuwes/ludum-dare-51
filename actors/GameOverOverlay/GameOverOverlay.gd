extends Control

onready var animation_player = $AnimationPlayer
onready var game_over_audio_stream_player = $GameOverAudioStreamPlayer
onready var score_label = $ScoreLabel
onready var can_restart_timer = $CanRestartTimer

var can_restart = false

func show_game_over(score):
	can_restart = false
	
	score_label.text = "Your score: " + String(score)
	
	animation_player.play("fade_in")
	game_over_audio_stream_player.play()
	
	can_restart_timer.wait_time = 2.0
	can_restart_timer.one_shot = true
	can_restart_timer.start()

func _input(event):
	if can_restart and event is InputEventKey:
		if event.pressed:
			get_tree().change_scene("res://scenes/Game.tscn")

func _on_CanRestartTimer_timeout():
	can_restart = true
