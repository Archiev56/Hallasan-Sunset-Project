extends Node2D

@export var mini_worm_node: PackedScene = preload("res://Hallasan-Sunset/Enemies/Bosses/Ironoak/Branch/tree_branch.tscn")

func _on_timer_timeout():
	spawn()

func spawn():
	# Access the player instance from the PlayerManager
	var player = PlayerManager.player
	if player:
		# Spawn the enemy at the player's current position
		var mini_worm = mini_worm_node.instantiate()
		mini_worm.position = player.global_position
		get_tree().current_scene.call_deferred("add_child", mini_worm)
	else:
		print("Error: Player instance not found in PlayerManager!")
