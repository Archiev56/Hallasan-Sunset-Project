extends Node2D

func _on_animation_player_animation_finished(anim_name: String) -> void:
	get_tree().change_scene_to_file("res://Hallasan-Sunset/Levels/Act1/Forest/Act_1_Scene_1.tscn")
