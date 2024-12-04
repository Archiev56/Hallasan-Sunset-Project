extends Area2D

@export var heal_amount : int = 1  # Amount of health the heart restores

signal collected(player)

func _ready():
	# Connect the signal to detect when the player enters the heart's area
	connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body):
	
	# Check if the body is the player
	if body is Player:
		$Heart.play()
		emit_signal("collected", body)
		
		body.heal(heal_amount) 
		
		queue_free()  # Remove the heart from the scene
