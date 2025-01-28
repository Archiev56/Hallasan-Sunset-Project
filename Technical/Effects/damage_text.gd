class_name DamageText extends Node2D

var travel_distance: Vector2 = Vector2(10, -20)

func start(_text: String, _pos: Vector2) -> void:
	# Set text and position
	$Label.text = _text
	global_position = _pos

	# Randomize travel distance and duration
	travel_distance.y *= randf_range(0.5, 1.5)
	travel_distance.x *= randf_range(-1.5, 1.5)
	
	
	var duration: float = randf_range(0.75, 1.25)

	# Create a tween to animate
	var tween: Tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property( self, "global_position", global_position + travel_distance, duration)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), duration).set_ease( Tween.EASE_IN)
	
	tween.chain().tween_callback(self.queue_free)
	
	pass
