class_name State_Walk extends State

@export var move_speed: float = 800.0
@export var dash_speed: float = 200.0
@export var dash_duration: float = 0.2  # Duration of the dash in seconds
@export var max_speed: float = 85.0
@export var accel: float = 1200.0
@export var friction: float = 600.0

@export var player_hud_path: String = "res://Hallasan-Sunset/Player/GUI/Player_hud/player_hud.tscn"
var player_hud: Node = null  # Reference to the instantiated PlayerHUD

var dash_scene = preload("res://Hallasan-Sunset/Player/Technical/Moves/Dash copy/dash.tscn")

@onready var idle: State = $"../Idle"
@onready var attack: State = $"../Attack"
@onready var walk_left_audio: AudioStreamPlayer2D = $"../../Audio/Walk"
@onready var dust_particles: GPUParticles2D = $"../../DustParticles"
@onready var dash_particles: GPUParticles2D = $"../../DashParticles"  # Optional: for dash effect
@onready var dash_audio = $"../../Audio/Dash"
@onready var hit_box = $"../../Interactions/HitBox"
@onready var animation_player = $"../../AnimationPlayer"
@onready var sprite = $"../../Sprite2D"
@onready var dash_node = $"../../Dash"

var sound_cooldown: float = 0.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var input: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Load the PlayerHUD scene
	var player_hud_scene = load(player_hud_path)
  # Use preload or load
	if player_hud_scene:
		player_hud = player_hud_scene.instantiate()
		get_tree().root.add_child(player_hud)  # Add PlayerHUD to the root or desired parent node
		print("PlayerHUD loaded and instantiated successfully:", player_hud)
	else:
		print("Failed to load PlayerHUD scene from path:", player_hud_path)
	
	# Existing _ready logic
	var dash_scene = dash_scene.instantiate()
	add_child(dash_scene)

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
			hit_box.is_invulnerable = false
			player.velocity = player.direction * move_speed
			player.UpdateAnimation("walk")  # Ensure animation reverts to walk
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
	elif _event.is_action_pressed("dash"):
		if not start_dashing():
			print("Not enough energy to dash!")  # Debugging message
	return null

func handle_walking(delta: float):
	input = get_input()

	# Apply friction if there's no input, otherwise accelerate
	if input == Vector2.ZERO:
		if player.velocity.length() > (friction * delta):
			player.velocity -= player.velocity.normalized() * (friction * delta)
		else:
			player.velocity = Vector2.ZERO
	else:
		player.velocity += input * accel * delta
		player.velocity = player.velocity.limit_length(max_speed)

	# Smoothly transition velocity after dashing
	if not is_dashing and player.velocity.length() > move_speed:
		player.velocity = player.velocity.normalized().lerp(player.velocity.normalized() * move_speed, delta * friction)

	# Play walking sound at intervals
	sound_cooldown -= delta
	if sound_cooldown <= 0.0 and input != Vector2.ZERO:
		walk_left_audio.pitch_scale = randf_range(0.9, 1.1)
		walk_left_audio.play()
		sound_cooldown = 0.4

	# Update player animation
	if player.set_direction():
		player.UpdateAnimation("walk")

func get_input() -> Vector2:
	var direction = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	return direction.normalized()

func start_dashing() -> bool:
	print("Checking energy for dash...")  # Debugging message
	if player_hud and player_hud.deduct_energy_for_dodge():
		print("Dash successful!")  # Debugging message
		is_dashing = true
		player.UpdateAnimation("dodge")
		animation_player.play("dodge_" + player.AnimDirection())
		hit_box.is_invulnerable = true
		dash_audio.play()
		dash_timer = dash_duration
		player.velocity = player.direction * dash_speed
		if dash_particles:
			dash_particles.emitting = true
		if dash_node:
			dash_node.instance_ghost()
		else:
			print("Error: Dash node not found!")
		return true
	else:
		print("Not enough energy or PlayerHUD not found!")  # Debugging message
		return false

func _on_AnimationPlayer_animation_finished(animation_name: String):
	if animation_name.begins_with("dodge_"):  # If a dodge animation ends
		if player.direction != Vector2.ZERO:
			player.UpdateAnimation("walk")
		else:
			player.UpdateAnimation("idle")
