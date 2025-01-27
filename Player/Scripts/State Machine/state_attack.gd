class_name State_Attack extends State

var attacking : bool = false

@export var attack_sound : AudioStream
@export_range(1,20,0.5) var decelerate_speed : float = 5.0


@onready var idle : State = $"../Idle"
@onready var walk : State= $"../Walk"
@onready var charge_attack = $"../ChargeAttack"



@onready var animation_player : AnimationPlayer = $"../../AnimationPlayer"
@onready var attack_anim : AnimationPlayer = $"../../Sprite2D/AttackEffectSprite/AnimationPlayer"
@onready var audio : AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var hurt_box : HurtBox = $"../../Interactions/HurtBox"

## What happens when the player enters this State?
func enter() -> void:
	
	player.UpdateAnimation("attack")
	attack_anim.play( "attack_" + player.AnimDirection() )
	animation_player.animation_finished.connect( _end_attack )
	
	
	
	
	attacking = true
	await get_tree().create_timer( 0.075 ).timeout
	if attacking: 
		hurt_box.monitoring = true
	pass


## What happens when the player exits this State?
func exit() -> void:
	animation_player.animation_finished.disconnect( _end_attack )
	attacking = false
	hurt_box.monitoring = false
	pass


## What happens during the _process update in this State?
func Process( _delta : float ) -> State:
	player.velocity -= player.velocity * decelerate_speed * _delta
	if attacking == false:
		if player.direction == Vector2.ZERO:
			return idle
		else:
			return walk
	return null


## What happens during the _physics_process update in this State?
func Physics( _delta : float ) -> State:
	return null

func handle_input( _event: InputEvent ) -> State:
	return null

func _end_attack( _newAnimName : String ) -> void:
	if Input.is_action_pressed("attack"):
		state_machine.change_state( charge_attack )
	attacking = false
