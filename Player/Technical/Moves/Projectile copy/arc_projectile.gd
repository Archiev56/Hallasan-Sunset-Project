extends Node2D

var initial_speed: float
var throw_angle_degrees: float
const gravity: float = 9.8
var time: float = 0.0


var initial_position: Vector2
var throw_direction: Vector2

var z_axis = 0.0 # Simulate throwing the projectile on the z-axis by adding the z-axis to the y-axis
var is_launch: bool = false

var time_mult: float = 6.0
var player_direction: Vector2 = Vector2(1, 0) # Default is facing right
var has_reached_peak: bool = false # Tracks if the projectile has reached its peak
var has_exploded: bool = false # Tracks if the explosion has started
var frozen_position: Vector2 # Keeps the position where the projectile freezes

# Reference to AnimationPlayer node
@onready var animation_player = $Projectile/AnimationPlayer

# Reference to the hurt box (Area2D)
@onready var hurt_box = $Projectile/HurtBox

# Reference to the CollisionShape2D inside the hurt box
@onready var hurt_box_collision_shape = $hurt_box/CollisionShape2D

# Reference to the player node (replace with actual path to the player node in your scene)
@onready var player = get_parent().get_node(".")

# Reference to the Sizzle and Explosion sound nodes
@onready var sizzle_sound: AudioStreamPlayer2D = $Sizzle
@onready var explosion_sound: AudioStreamPlayer2D = $Explosion

func _ready():
	# Make the projectile invisible and inactive initially
	visible = false
	set_physics_process(false)  # Disable physics updates
	hurt_box_collision_shape.disabled = true  # Disable collision shape

	# Correct signal connection using Callable
	animation_player.connect("animation_finished", Callable(self, "_on_AnimationPlayer_animation_finished"))

func _process(delta):
	if not has_exploded:
		time += delta * time_mult

		# Update player direction based on input
		if Input.is_action_pressed("ui_left"):
			player_direction = Vector2(-1, 0) # Facing left
		elif Input.is_action_pressed("ui_right"):
			player_direction = Vector2(1, 0)  # Facing right
		elif Input.is_action_pressed("ui_up"):
			player_direction = Vector2(0, -1) # Facing up
		elif Input.is_action_pressed("ui_down"):
			player_direction = Vector2(0, 1)  # Facing down

		# Press "L" to throw the bomb
		if Input.is_action_just_pressed("bomb") and not is_launch:
			LaunchProjectile(player.global_position, player_direction, 150, 60)

		if is_launch and not has_exploded:
			z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * time - 0.5 * gravity * pow(time, 2)

			# Check if the bomb has hit the ground
			if z_axis <= 0 and has_reached_peak:
				exploded()  # Call the exploded function to freeze the position
			else:
				if z_axis < initial_speed * sin(deg_to_rad(throw_angle_degrees)) * 0.1:  # Approximates peak
					has_reached_peak = true

				var x_axis: float = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * time
				global_position = initial_position + throw_direction * x_axis  # Move along the x-axis
				$Projectile.position.y = -z_axis  # Move the projectile along the y axis based on the simulated z-axis
	else:
		# Freeze position after explosion
		global_position = frozen_position

# Launches the projectile in the specified direction from the player position
func LaunchProjectile(initial_pos: Vector2, direction: Vector2, desired_distance: float, desired_angle_deg: float):
	# Make the projectile visible and active when thrown
	visible = true
	set_physics_process(true)  # Enable physics updates
	hurt_box_collision_shape.disabled = true  # Disable hurt box collision until the bomb hits the ground

	initial_position = initial_pos
	throw_direction = direction.normalized()

	throw_angle_degrees = desired_angle_deg
	# Calculate initial speed based on desired distance and angle
	initial_speed = pow(desired_distance * gravity / sin(2 * deg_to_rad(desired_angle_deg)), 0.5)

	global_position = initial_position
	time = 0.0
	has_reached_peak = false
	has_exploded = false
	
	z_axis = 0
	is_launch = true

	# Play BombLive animation when thrown
	animation_player.play("BombLive")

	# Play the sizzle sound when the bomb is thrown
	sizzle_sound.play()

# Called when the animation finishes
func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name == "Explode":
		reset_projectile()

# Resets the projectile's state for reuse
func reset_projectile():
	# Fetch the player's position again before resetting
	initial_position = player.global_position
	is_launch = false
	time = 0.0
	has_reached_peak = false
	has_exploded = false
	z_axis = 0
	global_position = initial_position

	# Reset the scale to its original size (1x)
	scale = Vector2(1, 1)

	# Make the projectile invisible and inactive again
	visible = false
	set_physics_process(false)
	hurt_box_collision_shape.disabled = true  # Disable hurt box's collision shape again

	animation_player.play("Idle")

# Called when the hurt box detects a collision
func _on_hurt_box_body_entered(body):
	if body != self and hurt_box_collision_shape.disabled == false and body.has_method("take_damage"):
		body.take_damage(5, global_position)

# Freezes the projectile in place after it explodes and makes it 2x bigger
func exploded():
	is_launch = false
	has_exploded = true
	z_axis = 0
	
	# Stop further movement and processing
	set_physics_process(false)
	
	# Store the current position to freeze it
	frozen_position = global_position
	
	# Make the projectile 2x bigger by adjusting its scale
	scale *= 2
	
	# Enable the hurt box and play explosion animation
	hurt_box_collision_shape.disabled = false
	animation_player.play("Explode")
	

	# Play the explosion sound when the bomb hits the ground
	explosion_sound.play()
