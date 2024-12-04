extends CharacterBody2D

@onready var ray_cast = $RayCast2D
@onready var player
@onready var progress_bar = $ProgressBar
@onready var hitbox : Area2D = $HitBox 
@onready var gpu_particles_2d = $GPUParticles2D

var direction = Vector2.RIGHT
var camera2D : Camera2D
var cameraShakeNoise : FastNoiseLite
@onready var sprite: AnimatedSprite2D = $Bee

var health = 20:
	set(value):
		health = value
		progress_bar.value = value
		if health <= 0:
			_die()

var speed = 100.0
var stop_distance = 50.0  # Distance at which the bee stops approaching the player
var can_shoot = true
var shoot_interval = 1.5  # Time between shots
var last_shoot_time = 0.0

func _ready():
	set_physics_process(true)  # Enable the physics process
	player = get_node_or_null("/root/Player")
	if player == null:
		print("Player not found yet.")
	
	camera2D = get_node("/root/playground/Player/Camera2D")
	cameraShakeNoise = FastNoiseLite.new()
	ray_cast.enabled = true  # Make sure RayCast2D is enabled
	
	# Connect the player's Hurt_box signal to detect when the enemy enters
	if is_instance_valid(player):  # Check if the player exists
		player.hurt_box.connect("body_entered", Callable(self, "_on_hurt_box_entered"))

func _physics_process(_delta):
	if not is_instance_valid(player):
		player = get_tree().current_scene.get_node("Player")
	
	if is_instance_valid(player):
		# Calculate direction towards player
		var distance_to_player = player.global_position.distance_to(global_position)
		
		if distance_to_player > stop_distance:  # Only move if distance is greater than stop_distance
			direction = (player.global_position - global_position).normalized()
			
			# Set RayCast2D to point towards the player
			var raycast_offset = player.global_position - global_position
			ray_cast.target_position = raycast_offset  # Continuously update the raycast direction
			
			# Check if raycast hit the player
			if ray_cast.is_colliding() and ray_cast.get_collider() == player:
				print("RayCast hit the player!")
				

			# Move the enemy towards the player
			velocity = direction * speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO  # Stop movement when close to the player


		# Optionally disable raycast tracking for a brief moment or until shooting finishes
		
		
		# Re-enable tracking after the delay or after shooting finishes
		ray_cast.enabled = true  # This will resume the raycast to keep tracking the player



# Function to handle when the player enters the enemy's Hurt_box
func _on_hurt_box_entered(body: Node):
	if body == self and Input.is_action_pressed("attack"):  # Ensure the attack action is being pressed
		_on_hitbox_damaged(1)  # Apply damage to the enemy

func take_damage(damage: int, from: Vector2) -> void:
	health -= damage


	# Play hurt animation and particle effect
	if health <= 0:
		_die()

# Function to handle damage to the enemy
func _on_hitbox_damaged(damage: int):
	health -= damage

	gpu_particles_2d.restart()
	gpu_particles_2d.emitting = true



func SetShader_BlinkIntensity(newValue: float):
	sprite.material.set_shader_parameter("blink_intensity", newValue)


# Handle the bee's death and spawn heart if applicable
func _die():

	queue_free()  # Remove the bee from the scene
