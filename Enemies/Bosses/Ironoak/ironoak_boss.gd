extends CharacterBody2D
 
@onready var animation_player = $AnimationPlayer

@export var hp : int = 3
 
func _on_animation_finished(anim_name):
	animation_player.play("idle")
 
 
func _on_player_entered(body):
	animation_player.play("attack")
 
 
func _on_hit_box_entered(body):
	body.take_damage()
 
