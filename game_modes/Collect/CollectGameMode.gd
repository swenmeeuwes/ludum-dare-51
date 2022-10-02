extends GameMode

var collectable_prefab = preload("res://actors/Collectable/Collectable.tscn")

var collectable_size = Vector2(16, 16)

var sushi_themed_sprites = [
	preload("res://assets/sushi_1.png"),
	preload("res://assets/sushi_2.png"),
	preload("res://assets/sushi_3.png"),
	preload("res://assets/sushi_4.png"),
	preload("res://assets/sushi_5.png"),
	preload("res://assets/sushi_6.png"),
	preload("res://assets/sushi_7.png"),
	preload("res://assets/sushi_8.png"),
	preload("res://assets/sushi_9.png"),
]

var shoe_themed_sprites = [
	preload("res://assets/shoe_1.png"),
	preload("res://assets/shoe_2.png"),
	preload("res://assets/shoe_3.png"),
	preload("res://assets/shoe_4.png"),
	preload("res://assets/shoe_5.png"),
]

onready var progression_slider = $Control/ProgressionSlider

var current_theme: GameModeTheme

var collectables = []

var goal_percentage_01 = .5
var amount_collected = 0
var start_amount = 0

func _init():
	themes = [
		GameModeTheme.new(sushi_themed_sprites, "All you can eat!", preload("res://sounds/all_you_can_eat.ogg")),
		GameModeTheme.new(shoe_themed_sprites, "Shop till you drop!", preload("res://sounds/shop_till_you_drop.ogg")),
	]
	
	current_theme = get_theme()
	
	announcement = current_theme.themed_announcement
	announcement_audio_stream = current_theme.themed_announcement_audio

func _ready():
	progression_slider.rect_scale = Vector2.ZERO
	progression_slider.value = 0

func start():
	start_amount = 10 + 10 * difficulty_level
	amount_collected = 0
	goal_percentage_01 = min(.8, .25 + .07 * difficulty_level)
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(progression_slider, "rect_scale", Vector2.ONE, .45)
	
	for i in range(0, start_amount):
		_spawn_collectable()

func end():
	for collectable in collectables:
		_despawn_collectable(collectable)
	
	# victory condition: progress meter filled
	var percentage_collected = amount_collected / start_amount
	if percentage_collected < goal_percentage_01:
		lose()

func _spawn_collectable():
	var collectable = collectable_prefab.instance()
	collectable.position = _get_random_location()
	
	var themed_sprite = current_theme.themed_sprites[randi() % current_theme.themed_sprites.size()]
	collectable.set_texture(themed_sprite)
	
	_register_collectable(collectable)
	
	add_child(collectable)

func _despawn_collectable(collectable):
	collectable.despawn()

func _get_random_location():
	var x = rand_range(collectable_size.x, screen_size.x - collectable_size.x)
	var y = rand_range(collectable_size.y, screen_size.y - collectable_size.y)
	
	return Vector2(x, y)

func _update_progress_slider():
	if amount_collected == 0:
		return
	
	var percentage_collected = amount_collected / start_amount
	var percentage_until_goal = percentage_collected / goal_percentage_01 
	var slider_value = floor(percentage_until_goal * 100)
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(progression_slider, "value", slider_value, .45)
#	progression_slider.value

func _register_collectable(collectable):
	collectable.connect("pick_up", self, "_on_Collectable_pick_up")
	collectables.append(collectable)

func _deregister_collectable(collectable):
	collectable.disconnect("pick_up", self, "_on_Collectable_pick_up")
	var collectable_index = collectables.find(collectable)
	collectables.remove(collectable_index)

func _on_Collectable_pick_up(collectable):
	amount_collected += 1
	_deregister_collectable(collectable)
	_update_progress_slider()

func _on_WarningTimer_timeout():
	var percentage_collected = amount_collected / start_amount
	if percentage_collected < goal_percentage_01:
		# warn player that the player has to hurry up
		var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_loops(5)
		tween.tween_property(progression_slider, "rect_scale", Vector2.ONE * 1.05, .45)
		tween.tween_property(progression_slider, "rect_scale", Vector2.ONE, .45)
