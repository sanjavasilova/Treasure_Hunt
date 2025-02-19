extends RigidBody3D

var mouse_sensitivity := 0.007
var twist_input := 0.0
var pitch_input := 0.0

var jump_force := 5.0
var is_on_ground := false

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var animation_player := $AuxScene/AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	add_to_group("player") 
	
	if animation_player.has_animation("Idle0"): 
		animation_player.play("Idle0")
	else:
		var animations = animation_player.get_animation_list()
		if animations.size() > 0:
			animation_player.play(animations[0])

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	is_on_ground = false
	for i in range(state.get_contact_count()):
		var contact := state.get_contact_local_normal(i)
		if contact.dot(Vector3.UP) > 0.5:
			is_on_ground = true
			break

func _process(delta: float) -> void:
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")  
	input.z = Input.get_axis("move_forward", "move_back")
	
	if input.x != 0:
		var rotation_speed = 5.0
		rotate_y(-input.x * rotation_speed * delta) 
	
	var move_direction = transform.basis * Vector3(input.x, 0, input.z)
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	apply_central_force(move_direction * 1200.0 * delta)
	
	if Input.is_action_just_pressed("jump") and is_on_ground:
		apply_impulse(Vector3.UP * jump_force)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x,
	 deg_to_rad(-30), 
	 deg_to_rad(30)
	)
	
	twist_input = 0.0
	pitch_input = 0.0

	if input.length() > 0:
		if not animation_player.is_playing() or animation_player.current_animation != "Walking0":
			animation_player.play("Walking0")
	else:
		if animation_player.is_playing() and animation_player.current_animation == "Walking0":
			animation_player.play("Idle0")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * mouse_sensitivity)
			
			pitch_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
			pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-30), deg_to_rad(30))
