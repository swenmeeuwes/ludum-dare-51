extends Node
class_name GameMode

signal lose

var screen_size
var themes = []

var announcement = "[Unknown]"
var announcement_audio_stream
var player
var difficulty_level = 1

func initialize(screen_size, player, difficulty_level):
	self.screen_size = screen_size
	self.player = player
	self.difficulty_level = difficulty_level

func start():
	pass

func end():
	pass

func lose():
	print("minigame lost!")
	emit_signal("lose")

func get_theme():
	return themes[randi() % themes.size()]
