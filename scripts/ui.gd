extends CanvasLayer

@onready var score_label: Label = $Control/ScoreLabel
@onready var game_over_label: Label = $Control/GameOverLabel
@onready var timer_label: Label = $Control/TimerLabel
@onready var try_again_button: Button = $Control/TryAgainButton
@onready var background_music: AudioStreamPlayer = $Control/AudioStreamPlayer

func _ready():
	score_label.text = "Chests: 0/10"
	game_over_label.hide()
	try_again_button.hide()

	score_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	timer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	try_again_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	try_again_button.pressed.connect(_on_try_again_pressed)
	$Control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _on_try_again_pressed() -> void:	
	get_tree().paused = false
	
	background_music.play()
	
	var current_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene)
