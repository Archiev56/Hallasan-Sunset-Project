class_name State_pre_walk extends State

@onready var walk : State = $"../Walk"
@onready var attack : State = $"../Attack"

var pre_walk_speed : float = 195.0 # Initial speed during pre-walk
var max_pre_walk_duration : float = 0.025 # Duration of pre-walk state in seconds
var timer : float = 0.0

# Called when the player enters this state
func enter() -> void:
	player.UpdateAnimation("walk") # Use a distinct animation if available
	timer = 0.0 # Reset the timer

# Called when the player exits this state
func exit() -> void:
	player.velocity = Vector2.ZERO # Ensure velocity is cleared

# Updates every frame in the main loop
func Process(_delta : float) -> State:
	if player.direction == Vector2.ZERO:
		return null # Stay in this state if no direction is provided

	# Gradually build up speed over time
	timer += _delta
	player.velocity = player.direction.normalized() * lerp(pre_walk_speed, player.max_speed, timer / max_pre_walk_duration)

	# Transition to walking state if the timer exceeds the duration
	if timer >= max_pre_walk_duration:
		return walk

	return null

# Updates every frame in the physics loop
func Physics(_delta : float) -> State:
	return null

# Handles input events
func handle_input(_event : InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack # Transition to attack state if "attack" action is pressed
	return null
