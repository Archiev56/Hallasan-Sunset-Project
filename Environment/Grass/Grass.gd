extends StaticBody2D

@onready var body = Player
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _on_area_2d_body_entered(body):
	animation_player.play("grass_move")
