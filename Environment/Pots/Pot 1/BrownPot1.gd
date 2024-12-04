
extends Node2D

@onready var animation_player: AnimatedSprite2D = $Sprite2D
var cameraShakeNoise : FastNoiseLite
var camera2D : Camera2D

func _ready():
	# Connect the damaged signal using Callable
	camera2D = get_node("/root/playground/Player/Camera2D")
	cameraShakeNoise = FastNoiseLite.new()
	$HitBox.damaged.connect(Callable(self, "take_damage"))
	
	# Connect the animation_finished signal of the AnimationPlayer
	animation_player.animation_finished.connect(Callable(self, "_on_animation_finished"))

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		print("Player entered plant hitbox")
	

func take_damage(_damage: HurtBox) -> void:
	cameraShakeNoise = FastNoiseLite.new()
	var camera_tween = get_tree().create_tween()
	camera_tween.tween_method(StartCameraShake, 3.0, 1.0, 0.5)
	# Play the destroyed animation
	animation_player.play("default")

func StartCameraShake(intensity: float):
	var cameraOffset = cameraShakeNoise.get_noise_1d(Time.get_ticks_msec()) * intensity
	camera2D.offset.x = cameraOffset
	camera2D.offset.y = cameraOffset
# Signal handler for when the animation finishes
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "default":
		queue_free()  # Only destroy the plant after the destroyed animation is done



