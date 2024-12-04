class_name State_Walk extends State

@export var move_speed: float = 200.0
@export var dash_speed: float = 200.0
@export var dash_duration: float = 0.2  # Duration of the dash in seconds
@export var max_speed: float = 80.0
@export var accel: float = 1200.0
@export var friction: float = 600.0
@onready var idle: State = $"../Idle"
@onready var attack: State = $"../Attack"
@onready var walk_left_audio: AudioStreamPlayer2D = $"../../Audio/Walk"
@onready var dust_particles: GPUParticles2D = $"../../DustParticles"
@onready var dash_particles: GPUParticles2D = $"../../DashParticles"  # Optional: for dash effect
@onready var dash = $"../../Audio/Dash"

var sound_cooldown: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var input: Vector2 = Vector2.ZERO

func enter() -> void:
	player.UpdateAnimation("walk")
	sound_cooldown = 0.0
	dust_particles.emitting = true
	is_dashing = false

func exit() -> void:
	dust_particles.emitting = false
	if dash_particles:
		dash_particles.emitting = false

func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO and not is_dashing:
		return idle

	if is_dashing:
		dash_timer -= _delta
		if dash_timer <= 0.0:
			is_dashing = false
			player.velocity = player.direction * move_speed
			if dash_particles:
				dash_particles.emitting = false
	else:
		handle_walking(_delta)

	return null

func Physics(_delta: float) -> State:
	player.move_and_slide()  # Ensure this uses calculated velocity
	return null

func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	elif _event.is_action_pressed("dash") and not is_dashing:
		start_dashing()
	return null

func handle_walking(delta: float):
	input = get_input()

	if input == Vector2.ZERO:
		if player.velocity.length() > (friction * delta):
			player.velocity -= player.velocity.normalized() * (friction * delta)
		else:
			player.velocity = Vector2.ZERO
	else:
		player.velocity += input * accel * delta
		player.velocity = player.velocity.limit_length(max_speed)

	sound_cooldown -= delta
	if sound_cooldown <= 0.0 and input != Vector2.ZERO:
		walk_left_audio.pitch_scale = randf_range(0.9, 1.1)
		walk_left_audio.play()
		sound_cooldown = 0.4

	if player.set_direction():
		player.UpdateAnimation("walk")

func get_input() -> Vector2:
	var direction = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	return direction.normalized()

func start_dashing():
	is_dashing = true
	dash.play()
	dash_timer = dash_duration
	player.velocity = player.direction * dash_speed
	if dash_particles:
		dash_particles.emitting = true
