extends CanvasLayer

signal shown
signal hidden

@onready var button_save: Button = $Control/VBoxContainer/Button_save
@onready var button_load: Button = $Control/VBoxContainer/Button_load
@onready var item_description: Label = $Control/ItemDescription
@onready var audio_stream_player: AudioStreamPlayer2D = $Control/AudioStreamPlayer2D

var is_paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_pause_menu()
	button_save.pressed.connect( _on_save_pressed )
	button_load.pressed.connect( _on_load_pressed )
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		if is_paused == false:
			if DialogSystem.is_active:
				return
			show_pause_menu()
		else:
			hide_pause_menu()
		get_viewport().set_input_as_handled()
		
		
func show_pause_menu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	shown.emit()

func hide_pause_menu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()


func _on_save_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.save_game()
	hide_pause_menu()
	pass
	
func _on_load_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.load_game()
	await LevelManager.level_load_started
	hide_pause_menu()
	pass
	
func update_item_description( new_text : String ) -> void:
	item_description.text = new_text


# Function to handle going to the main menu
func _on_main_menu_pressed():
	# Ensure the game is unpaused and the pause menu is hidden before switching scenes
	get_tree().paused = false
	$".".hide()
	get_tree().change_scene_to_file("res://UI/Main Menu/main_menu.tscn")



# Function to quit the game
func _on_quit_pressed():
	get_tree().quit()
	
	
func play_audio( audio : AudioStream ) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()
