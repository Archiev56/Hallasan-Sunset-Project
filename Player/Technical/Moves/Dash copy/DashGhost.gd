extends Sprite2D

func _ready():
	# Create a new tween (SceneTreeTween)
	var tween = create_tween()

	# Tween the 'modulate:a' (alpha) property from 1.0 to 0.0 over 0.5 seconds with linear transition and ease in-out
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
