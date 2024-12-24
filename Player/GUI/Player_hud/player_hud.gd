extends CanvasLayer

var hearts: Array[HeartGUI] = []
var max_energy: int = 5
var current_energy: int = max_energy  # Initialize energy to full
var energy_refill_rate: float = 1.0  # Energy points per second
var energy_deduction_per_dodge: int = 1
@onready var energy_refill_timer: Timer = $Timer

@onready var game_over: Control = $Control/GameOver
@onready var continue_button: Button = $Control/GameOver/VBoxContainer/ContinueButton
@onready var title_button: Button = $Control/GameOver/VBoxContainer/TitleButton
@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

@onready var boss_ui: Control = $Control/BossUI
@onready var boss_hp_bar: TextureProgressBar = $Control/BossUI/TextureProgressBar
@onready var boss_label: Label = $Control/BossUI/Label
@export var energy_bar: TextureProgressBar  # Assign via Inspector

func _ready():
	# Check energy bar assignment
	if not energy_bar:
		print("Error: Energy bar is not assigned in the Inspector!")
	else:
		print("Energy bar successfully assigned:", energy_bar)

	# Initialize energy bar to full
	current_energy = max_energy
	update_energy_bar()

	# Setup hearts
	for child in $Control/HFlowContainer.get_children():
		if child is HeartGUI:
			hearts.append(child)
			child.visible = false

	hide_game_over_screen()
	continue_button.pressed.connect(load_game)
	LevelManager.level_load_started.connect(hide_game_over_screen)
	hide_boss_health()

	# Configure energy refill timer
	if energy_refill_timer:
		energy_refill_timer.wait_time = 1.0 / energy_refill_rate
		energy_refill_timer.autostart = true
		energy_refill_timer.one_shot = false
		energy_refill_timer.timeout.connect(refill_energy)
		energy_refill_timer.start()  # Ensure the timer starts
		print("Energy refill timer configured and started: ", energy_refill_timer.wait_time)
	else:
		print("Error: Energy refill timer is not found!")

func update_energy_bar() -> void:
	if energy_bar:
		energy_bar.value = float(current_energy) / float(max_energy) * 100
		print("Energy bar updated. Value: ", energy_bar.value)
	else:
		print("Error: Energy bar node is not assigned or does not exist!")

func deduct_energy_for_dodge() -> bool:
	print("Attempting to deduct energy. Current energy: ", current_energy)
	if current_energy >= energy_deduction_per_dodge:
		current_energy -= energy_deduction_per_dodge
		current_energy = max(current_energy, 0)  # Clamp to zero
		update_energy_bar()
		print("Energy deducted. Remaining energy: ", current_energy)
		return true
	else:
		print("Not enough energy to dash! Current energy: ", current_energy)
		return false

func refill_energy() -> void:
	print("Refilling energy. Current energy: ", current_energy)
	if current_energy < max_energy:
		current_energy += 1
		current_energy = min(current_energy, max_energy)  # Clamp to max
		update_energy_bar()
		print("Energy increased to: ", current_energy)
	else:
		print("Energy is already full. Current energy: ", current_energy)

func update_hp(_hp: int, _max_hp: int) -> void:
	update_max_hp(_max_hp)
	for i in _max_hp:
		update_heart(i, _hp)

func update_heart(_index: int, _hp: int) -> void:
	var _value: int = clampi(_hp - _index * 2, 0, 2)
	hearts[_index].value = _value

func update_max_hp(_max_hp: int) -> void:
	var _heart_count: int = roundi(_max_hp * 0.5)
	for i in hearts.size():
		if i < _heart_count:
			hearts[i].visible = true
		else:
			hearts[i].visible = false

func show_game_over_screen() -> void:
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP

	var can_continue: bool = SaveManager.get_save_file() != null
	continue_button.visible = can_continue

	animation_player.play("show_game_over")
	await animation_player.animation_finished

	if can_continue == true:
		continue_button.grab_focus()
	else:
		title_button.grab_focus()

func hide_game_over_screen() -> void:
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color(1, 1, 1, 0)

func load_game() -> void:
	await fade_to_black()
	SaveManager.load_game()

func fade_to_black() -> bool:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	PlayerManager.player.revive_player()
	return true

func play_audio(_a: AudioStream) -> void:
	audio.stream = _a
	audio.play()

func show_boss_health(boss_name: String) -> void:
	boss_ui.visible = true
	boss_label.text = boss_name
	update_boss_health(1, 1)

func hide_boss_health() -> void:
	boss_ui.visible = false

func update_boss_health(hp: int, max_hp: int) -> void:
	boss_hp_bar.value = clampf(float(hp) / float(max_hp) * 100, 0, 100)
