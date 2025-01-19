class_name Stats extends PanelContainer


@onready var label_level = $VBoxContainer/HBoxContainer/Label2
@onready var label_xp = $VBoxContainer/HBoxContainer2/Label2
@onready var label_attack = $VBoxContainer/HBoxContainer3/Label2
@onready var label_defense = $VBoxContainer/HBoxContainer4/Label2

func _ready() -> void:
	PauseMenu.shown.connect(update_stats)

func update_stats() -> void:
	var _p: Player = PlayerManager.player
	label_level.text = str(_p.level)
	label_xp.text = str(_p.xp) + "/" + str(PlayerManager.level_requirements[ _p.level ])
	label_attack.text = str(_p.attack)
	label_defense.text = str(_p.defense)
	pass
