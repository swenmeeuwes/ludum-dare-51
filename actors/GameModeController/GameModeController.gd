extends Node2D

onready var next_game_mode_timer = $NextGameModeTimer
onready var count_down_audio_stream_player = $CountDownAudioStreamPlayer

var game_modes = [
	preload("res://game_modes/Collect/CollectGameMode.tscn"),
	preload("res://game_modes/ChaseAvoid/ChaseAvoidGameMode.tscn"),
	preload("res://game_modes/Meteorites/MeteoritesGameMode.tscn"),
	preload("res://game_modes/BulletHell/BulletHellGameMode.tscn"),
	preload("res://game_modes/AvalancheGameMode/AvalancheGameMode.tscn"),
	preload("res://game_modes/DeliveryGameMode/DeliveryGameMode.tscn"),
]

var game_mode_index = 0

var player
var announcement_overlay
var score_overlay
var game_over_overlay

var score = 0
var game_modes_completed = 0
var current_game_mode = null

var screen_size = Vector2(480, 270)

var game_over = false
var count_down_played = false

func _ready():
	randomize()
	
	game_modes.shuffle()
	game_mode_index = 0
	
	player = get_node("../Player")
	announcement_overlay = get_node("../AnnouncementOverlay")
	score_overlay = get_node("../ScoreOverlay")
	game_over_overlay = get_node("../GameOverOverlay")
	
	player.initialize(screen_size)
	score_overlay.call_deferred("show_score", score)
	
	announcement_overlay.connect("faded_out", self, "_on_AnnouncementOverlay_faded_out")
	
	next_game_mode_timer.wait_time = 10 # Shameless Ludum Dare theme plug
	next_game_mode_timer.one_shot = true
	next_game_mode_timer.start()
	
	_prepare_next_game_mode()

func _process(delta):
	_handle_count_down_audio()

func game_over():
	if game_over:
		return
	
	game_over = true;
	next_game_mode_timer.stop()
	game_over_overlay.show_game_over(score)
	
	_end_current_game_mode()

func add_score(value):
	if game_over:
		return
	
	score += value
	score_overlay.show_score(score)

func get_difficulty_level():
	return 1 + floor(game_modes_completed / 4.0)
#	return 100 + floor(game_modes_completed / 1.0)

func _end_current_game_mode():
	if (current_game_mode != null):
		current_game_mode.end()
		current_game_mode.disconnect("lose", self, "_on_GameMode_lose")
		add_score(1)
		game_modes_completed += 1
		
#		current_game_mode.transform.origin = Vector2(screen_size.x * .5, screen_size.y * .5)
#		current_game_mode.position -= Vector2(screen_size.x * .5, screen_size.y * .5)
		
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(current_game_mode, "modulate:a", 0.0, .45)
		tween.connect("finished", self, "_destroy_game_mode", [current_game_mode])

func _prepare_next_game_mode():
	_end_current_game_mode()
	
	var next_game_mode = _get_next_game_mode()
	var next_game_mode_instance = next_game_mode.instance()
	add_child(next_game_mode_instance)
	
	current_game_mode = next_game_mode_instance
	current_game_mode.initialize(screen_size, player, get_difficulty_level())
	
	current_game_mode.connect("lose", self, "_on_GameMode_lose")
	
	announcement_overlay.call_deferred("show_announcement", next_game_mode_instance.announcement, next_game_mode_instance.announcement_audio_stream)

func _start_current_game_mode():
	current_game_mode.start()
	next_game_mode_timer.start()
	
	set_deferred("count_down_played", false)

func _get_next_game_mode():
	var next_game_modes = game_modes[game_mode_index]
	
	game_mode_index += 1
	if game_mode_index >= max(0, game_modes.size() - 3): # shuffle every 3 games
		game_modes.shuffle()
		game_mode_index = 0
	
	return next_game_modes

func _destroy_game_mode(game_mode_script):
	game_mode_script.queue_free()

func _handle_count_down_audio():
	if (!game_over and !count_down_played and next_game_mode_timer.time_left < 3):
		count_down_played = true
		count_down_audio_stream_player.play()

func _on_Timer_timeout():
	_prepare_next_game_mode()

func _on_AnnouncementOverlay_faded_out():
	_start_current_game_mode()

func _on_GameMode_lose():
	game_over()
