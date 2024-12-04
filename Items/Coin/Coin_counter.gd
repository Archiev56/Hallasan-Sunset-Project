extends Control

class_name Coincounter

@export var initial_coins: int = 0  # Starting coin count

var coin_count: int
var label: Label  # Reference to the Label node

func _ready():
	# Initialize the coin count
	coin_count = initial_coins
	
	# Get the label node (ensure this path is correct)
	label = $Label  # Adjust this path if the Label node is not a direct child of Coincounter
	
	# Check if the label was found correctly
	if label == null:
		print("Error: Label node not found!")
	else:
		print("Label node found successfully.")
	
	# Update the label to show the initial count
	update_coin_count()

func update_coin_count():
	if label != null:
		label.text = str(coin_count)
	else:
		print("Error: Label is null, cannot update text.")

func add_coins(amount: int):
	coin_count += amount
	update_coin_count()

func reset_coin_count():
	coin_count = 0
	update_coin_count()
