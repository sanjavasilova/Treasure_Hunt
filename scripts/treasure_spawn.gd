extends Node3D

@export var treasure_scene: PackedScene = preload("res://treasure_chest.tscn")
@export var spawn_area: Node3D = self 
@export var max_attempts: int = 10
@export var game_duration: float = 120.0 
@onready var background_music: AudioStreamPlayer = $AudioStreamPlayer
@onready var collect_audio: AudioStreamPlayer = $CollectAudio

const CHEST_COUNT = 10

@export var spawn_area_size: Vector3 = Vector3(64, 64, 64)
@export var spawn_area_layer_mask: int = 1

var collected_chests: int = 0 
var timer: Timer

@onready var score_label: Label = $CanvasLayer/Control/ScoreLabel
@onready var game_over_label: Label = $CanvasLayer/Control/GameOverLabel
@onready var timer_label: Label = $CanvasLayer/Control/TimerLabel
@onready var try_again_button: Button = $CanvasLayer/Control/TryAgainButton

func _ready():
	if treasure_scene == null:
		print("ERROR: No treasure scene assigned!")
		return

	if spawn_area == null:
		print("ERROR: No spawn area assigned!")
		return

	timer = Timer.new()
	timer.wait_time = game_duration
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

	score_label.text = "Chest: 0/10"
	game_over_label.hide() 
	timer_label.text = "Time Left: " + format_time(game_duration)  

	spawn_chests()

func _process(delta: float) -> void:
	if timer:
		var time_left = timer.time_left
		timer_label.text = "Time Left: " + format_time(time_left)

func format_time(time: float) -> String:
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	return "%02d:%02d" % [minutes, seconds]

func spawn_chests():
	var spawned_positions = [] 

	for _i in range(CHEST_COUNT):
		var chest_spawned = false
		for _j in range(max_attempts): 
			var random_pos = get_random_position()
			if is_position_free(random_pos, spawned_positions):
				var treasure = treasure_scene.instantiate()
				treasure.position = random_pos
				treasure.chest_collected.connect(_on_chest_collected) 
				add_child(treasure)
				spawned_positions.append(random_pos)
				chest_spawned = true
				break  
			
		if !chest_spawned:
			print("Failed to spawn chest after multiple attempts")

func get_random_position() -> Vector3:
	var random_x = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
	var random_z = randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
	
	var ground_height = 0.0 
	var random_pos = Vector3(random_x, ground_height, random_z)

	return random_pos

func is_position_free(pos: Vector3, spawned_positions: Array) -> bool:
	for other_pos in spawned_positions:
		if pos.distance_to(other_pos) < 2.0:
			return false

	var space_state = get_world_3d().direct_space_state
	var shape = BoxShape3D.new()
	shape.extents = Vector3(1.0, 1.0, 1.0) 

	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis(), pos)
	query.collide_with_areas = true
	query.collision_mask = spawn_area_layer_mask

	var results = space_state.intersect_shape(query)
	if results.size() > 0:
		return false 

	return true  

func _on_chest_collected() -> void:
	collected_chests += 1
	collect_audio.play()
	score_label.text = "Chests: " + str(collected_chests) + "/10"
	print("Chest collected! Total chests: ", collected_chests)

	if collected_chests >= CHEST_COUNT:
		end_game("YOU WON!\nYou collected all the chests!")

func _on_timer_timeout() -> void:
	end_game("Time's up!")

func end_game(message: String) -> void:
	print("Game Over: ", message)
	game_over_label.text = message 
	game_over_label.show() 
	try_again_button.show()
	try_again_button.mouse_filter = Control.MOUSE_FILTER_STOP
	try_again_button.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true 
	background_music.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
