extends GameMode

var delivery_target_prefab = preload("res://actors/DeliveryTarget/DeliveryTarget.tscn")
var deliverable_prefab = preload("res://actors/Package/Package.tscn")
var obstacle_prefab = preload("res://actors/MovingObstacle/MovingObstable.tscn")

var normal_themed_sprites = [
	preload("res://assets/package.png"), # deliverable
	preload("res://assets/house.png"), # delivery target
	preload("res://assets/truck_1.png"),
	preload("res://assets/truck_2.png"),
	preload("res://assets/truck_3.png"),
]

var delivery_targets = []
var deliverables = []
var obstacles = []

var current_theme: GameModeTheme

var delivery_target
var holding_deliverable
var deliverable_is_picked_up = false
var delivery_completed = false

func _init():
	themes = [
		GameModeTheme.new(normal_themed_sprites, "Delivery!", preload("res://sounds/delivery.ogg")),
	]

	current_theme = get_theme()

	announcement = current_theme.themed_announcement
	announcement_audio_stream = current_theme.themed_announcement_audio

func _ready():
	pass

func start():
	for i in min(3, floor(1 + .5 * (difficulty_level - 1))):
		_spawn_deliverable()
		_spawn_delivery_target()
	
	for j in min(10, floor(2 + 2 * (difficulty_level - 1))):
		_spawn_obstacle()

func end():
	if not _all_delivery_targets_fulfulled():
		lose()

func _all_delivery_targets_fulfulled():
	for target in delivery_targets:
		if not target.delivered:
			return false
	
	return true

func _spawn_obstacle():
	var obstacle = obstacle_prefab.instance()

	var themed_sprite = current_theme.themed_sprites[2 + randi() % (current_theme.themed_sprites.size() - 2)]
	obstacle.set_texture(themed_sprite)
	obstacle.set_moveable_area(screen_size - Vector2(24, 24))
	obstacle.set_movement_speed(min(64, 16 * difficulty_level))
	obstacle.set_player(player)

	obstacle.connect("kill_player", self, "_on_Obstacle_kill_player")

	obstacles.append(obstacle)

	add_child(obstacle)

func _spawn_deliverable():
	var deliverable = deliverable_prefab.instance()
	deliverable.position = _get_random_location()

	var themed_sprite = current_theme.themed_sprites[0]
	deliverable.set_texture(themed_sprite)

	deliverable.connect("pickup", self, "_on_Deliverable_pickup")
	deliverable.connect("can_pickup", self, "_on_Deliverable_can_pickup")

	deliverables.append(deliverable)

	add_child(deliverable)

func _spawn_delivery_target():
	delivery_target = delivery_target_prefab.instance()
	delivery_target.position = _get_random_location()

	var themed_sprite = current_theme.themed_sprites[1]
	delivery_target.set_texture(themed_sprite)

	delivery_target.connect("can_deliver", self, "_on_DeliveryTarget_can_deliver")

	add_child(delivery_target)
	
	delivery_targets.append(delivery_target)

func _get_random_location():
	var min_distance_from_others = 48
	var x = 0
	var y = 0
	var padding = 24
	
	for i in range(0, 500):
		x = rand_range(padding, screen_size.x - padding)
		y = rand_range(padding, screen_size.y - padding)
		
		if _point_is_distanced_from_others(Vector2(x, y), min_distance_from_others):
			break

	return Vector2(x, y)

func _point_is_distanced_from_others(point, min_dist):
	for deliverable in deliverables:
		if point.distance_to(deliverable.position) < min_dist:
			return false
	
	for delivery_target in delivery_targets:
		if point.distance_to(delivery_target.position) < min_dist:
			return false
	
	return true

func _on_Deliverable_pickup(deliverable):
	deliverable_is_picked_up = true
	
func _on_Deliverable_can_pickup(deliverable):
	if holding_deliverable != null:
		return
	
	deliverable.pickup()
	deliverable_is_picked_up = true
	holding_deliverable = deliverable

func _on_DeliveryTarget_can_deliver(delivery_target):
	if holding_deliverable != null and not delivery_target.delivered:
		deliverable_is_picked_up = false
		delivery_completed = true
		delivery_target.deliver()
		holding_deliverable.deliver()
		holding_deliverable = null

func _on_WarningTimer_timeout():
	for target in delivery_targets:
		if not target.delivered:
			target.show_warning()

func _on_Obstacle_kill_player():
	lose()
