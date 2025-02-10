class_name EnergyBar extends Control

@onready var energy_bar = $"Energy Bar"

var max_energy: int = 3
var current_energy: int = max_energy  # Initialize energy to full
var energy_deduction_per_dodge: int = 1

func _ready() -> void:
	
	pass
	
