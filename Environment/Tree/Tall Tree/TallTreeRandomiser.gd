extends Sprite2D

# Adjust these to control the randomization range for each tree
@export var min_wind_strength: float = 0.2
@export var max_wind_strength: float = 10.0
@export var min_change_interval: float = 1.5
@export var max_change_interval: float = 3.0

# The shader parameter name
const WIND_STRENGTH_PARAM = "Wind Strength"

# Timer to trigger changes
var timer := 0.0
var change_interval: float

func _ready() -> void:
	# Set a random starting interval and initial wind strength for each tree
	change_interval = randf_range(min_change_interval, max_change_interval)
	timer = randf_range(0.0, change_interval)
	randomize_wind_strength()

func _process(delta: float) -> void:
	# Increment the timer
	timer += delta
	if timer >= change_interval:
		# Randomize the wind strength
		randomize_wind_strength()
		# Reset timer and get a new random interval
		timer = 0.0
		change_interval = randf_range(min_change_interval, max_change_interval)

func randomize_wind_strength() -> void:
	# Set a new random wind strength value
	var new_strength = randf_range(min_wind_strength, max_wind_strength)
	$".".material.set_shader_parameter(WIND_STRENGTH_PARAM, new_strength)
