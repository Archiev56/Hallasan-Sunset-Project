extends Area2D

var direction = Vector2.RIGHT
var speed = 400

@onready var player : Player = get_node("/root/playground/Player")  # Ensure this path is correct!

func _ready():
	# Connect to the hurt_box signal of the bullet's Area2D (self)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	position += direction * speed * delta

# Free the bullet when it exits the screen
func _on_screen_exited():
	queue_free()

 # Destroy the bullet after hitting the player


func _on_bee_hurt_box_body_entered(body):
	if body is Player:
		body._take_damage(hurt_box : HurtBox)  # Apply damage to the player (make sure the Player script has this method)
		queue_free()  # Replace with function body.
