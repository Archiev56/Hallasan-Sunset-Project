class_name Bee_HurtBox
extends Area2D

@export var damage: int = 1  # Amount of damage this HurtBox deals
@onready var player = null  # Initialize as null, no need for "Player?"

func _ready():
	var parent_node = get_parent()
	


# Function to handle when the HurtBox enters another Area2D (like a HitBox)
func _on_area_entered(area: Area2D) -> void:
	if area is HitBox:
		area.take_damage(self)  # Call the take_damage function on the HitBox
