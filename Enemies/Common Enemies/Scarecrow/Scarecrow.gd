class_name Scarecrow extends CharacterBody2D

@export var health_max := 100

var health := health_max
var pushback_force := Vector2.ZERO

@onready var animation_player := $AnimationPlayer
@onready var hit_particles := $HitParticles
@onready var damage_spawning_point := $DamageSpawningPoint


func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	animation_player.play("hit")
	


func knock_back(source_position: Vector2) -> void:
	hit_particles.rotation = get_angle_to(source_position) + PI
	pushback_force = -global_position.direction_to(source_position) * 300


func _physics_process(delta: float) -> void:
	pushback_force = lerp(pushback_force, Vector2.ZERO, delta * 10)
	move_and_slide()
