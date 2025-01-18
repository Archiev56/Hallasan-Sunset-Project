class_name Player extends CharacterBody2D

signal direction_changed( new_direction: Vector2 )
signal player_damaged( hurt_box: HurtBox )

const DIR_4 = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]
const dash_speed = 200
const dash_duration = 0.5


@export var max_speed: float = 75.0

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

@onready var actionable_finder: Area2D = $Interactions/Direction/ActionableFinder
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $Audio/AudioStreamPlayer2D
@onready var effect_animation_player : AnimationPlayer = $EffectAnimationPlayer
@onready var behind_sprite = $Sprite2D/BehindObjectSprite
@onready var hit_box : HitBox  = $Interactions/HitBox
@onready var hurt_box : HurtBox  = $Interactions/HurtBox
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_machine : PlayerStateMachine = $StateMachine
@onready var lift: State_Lift = $StateMachine/Lift
@onready var held_item : Node2D = $Sprite2D/HeldItem
@onready var carry : State_Carry = $StateMachine/Carry

var invulnerable : bool = false
var hp : int = 6
var max_hp : int = 6
# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerManager.player = self
	state_machine.Initialize(self)
	hit_box.damaged.connect( _take_damage )
	update_hp(99)
	 
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()

	behind_sprite.position = sprite.position
	behind_sprite.texture = sprite.texture
	


	pass

# Handles the physics processing of the character.
func _physics_process(_delta):
	move_and_slide()


func set_direction() -> bool:
	if direction == Vector2.ZERO:
		return false
	
	var direction_id : int = int( round( ( direction + cardinal_direction * 0.1 ).angle() / TAU * DIR_4.size() ) )
	var new_dir = DIR_4[ direction_id ]
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	direction_changed.emit( new_dir )
	sprite.scale.x = 1 if cardinal_direction == Vector2.LEFT else -1
	return true


	



func UpdateAnimation( state : String) -> void:
	animation_player.play( state + "_" + AnimDirection())
	pass

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			
		if _event.is_action_pressed("interact"):
			PlayerManager.interact_pressed.emit()
			return

func change_sprite() -> void:
	sprite.texture = load("res://Hallasan-Sunset/Player/Animations/Idle/IdleDown/Untitled_Artwork-1.png")


func _take_damage( hurt_box : HurtBox ) -> void:
	if invulnerable == true:
		return
	
	if hp > 0:
		update_hp( -hurt_box.damage )
		player_damaged.emit( hurt_box )
	
	pass
	
func update_hp( delta : int ) -> void:
	hp = clampi( hp + delta, 0, max_hp )
	PlayerHud.update_hp( hp, max_hp )
	pass
	

	
func make_invulnerable( _duration : float = 1.0 ) -> void:
	invulnerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer( _duration ).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass
	
func pickup_item( _t : Throwable ) -> void:
	state_machine.change_state( lift )
	carry.throwable = _t
	pass

func revive_player() -> void:
	update_hp( 99 )
	state_machine.change_state( $StateMachine/Idle )
