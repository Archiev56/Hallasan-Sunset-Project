extends Area2D


signal collected

# Function to initialize the coin (called when the coin is ready in the scene)
func _ready():
	# Enable monitoring for detecting bodies (e.g., player)
	set_process(true)
	print("Coin is ready and active")

 # Remove the coin from the scene




func _on_body_entered(body):
	if body.is_in_group("player"):  # Check if it's the player that entered the area
		emit_signal("collected")  # Emit the signal when collected
		queue_free() # Replace with function body.
