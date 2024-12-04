extends StaticBody2D

@onready var state = "No apples"
@onready var player_in_area = false

var apple = preload("res://Environment/Apple Tree/Apple.tscn")
@export var item: InvItem
var player = null

func _ready():
	if state == "No apples":
		$growth_timer.start()  # Start the growth timer when there are no apples

func _process(delta):
	# Play the correct animation based on the state
	if state == "No apples":
		$AnimatedSprite2D.play("No apples")
	elif state == "Apples":
		$AnimatedSprite2D.play("Apples")
		
		# If the player is in the area and presses "e", harvest the apples
		if player_in_area and Input.is_action_just_pressed("attack"):
			state = "No apples"  # Set state back to no apples
			drop_apple()

# Detect when the player enters the pickable area
func _on_pickable_area_body_entered(body):
	if body.is_in_group("player"):  # Check if the body is the player
		player_in_area = true
		player = body
		
		

# Detect when the player exits the pickable area
func _on_pickable_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		

# Handle the growth timer timeout to spawn apples
func _on_growth_timer_timeout():
	if state == "No apples":
		state = "Apples"  # Change state to apples after the timer finishes


func drop_apple():
	var apple_instance = apple.instantiate()
	apple_instance.global_position = $Marker2D.global_position
	get_parent().add_child(apple_instance)
	player.collect(item)
	await get_tree().create_timer(3).timeout
	$growth_timer.start()
	
