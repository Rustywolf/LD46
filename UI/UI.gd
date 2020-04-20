extends Control

onready var pointer_text_label: RichTextLabel = $"PointerText"
var pointer_text := "" setget set_pointer_text

onready var money_total_label: RichTextLabel = $"Money/Entries/Total"
onready var money_entry_label: RichTextLabel = $"Money/Entries/Entry"
var money := 10000
var rent := 5000
var max_rent := 1000
var rent_rate := 15.0
var rent_timer := rent_rate
var rent_increase_rate_min := 30.0
var rent_increase_rate_max := 60.0
var rent_increase_timer := 0.0
var money_message_timeout := 5.0
var money_message_timer := 0.0

onready var game_over_modal: RichTextLabel = $"GameOverModal"
onready var retry_label: RichTextLabel = $"GameOverModal/CenterContainer/VBoxContainer/Retry"
onready var exit_label: RichTextLabel = $"GameOverModal/CenterContainer/VBoxContainer/Exit"

onready var helper_message_scene: PackedScene = \
	preload("res://UI/HelperMessage/HelperMessage.tscn")
onready var helper_messages: VBoxContainer = $"HelperMessages"
var helper_message_timers := []


func _ready():
	set_rent_increase_timer()
	

func set_rent_increase_timer():
	rent_increase_timer = rand_range(rent_increase_rate_min, rent_increase_rate_max)
	

func _process(delta):
	rent_timer -= delta
	if rent_timer <= 0:
		add_money("Rent", -rent)
		rent_timer = rent_rate
	
	rent_increase_timer -= delta
	if rent_increase_timer <= 0:
		rent += 100
		rent = min(rent, max_rent)
		set_rent_increase_timer()
	
	money_message_timer -= delta
	if money_message_timer > 0:
		money_entry_label.visible = true
	else:
		money_entry_label.visible = false
	
	var filtered_helper_message_timers := []
	for entry in helper_message_timers:
		entry.value -= delta
		if entry.value <= 0:
			helper_messages.remove_child(entry.child)
			entry.child.queue_free()
		else:
			filtered_helper_message_timers.push_back(entry)
	helper_message_timers = filtered_helper_message_timers
	

func set_pointer_text(value: String) -> void:
	pointer_text = value
	if value == "":
		pointer_text_label.visible = false
	else:
		pointer_text_label.visible = true
		pointer_text_label.bbcode_text = "[center]%s[/center]" % value
		

func add_money(reason: String, amount: int) -> void:
	money += amount
	money_total_label.bbcode_text = "[right]Money: $%s[/right]" % max(money, 0)
	
	var amount_str = "%s$%s" % [("-" if amount < 0 else ""), abs(amount)]
	money_entry_label.bbcode_text = "[right]%s: %s[/right]" % [reason, amount_str]
	money_entry_label.visible = true
	if amount < 0:
		money_entry_label.add_color_override("default_color", Color.darkred)
	else:
		money_entry_label.add_color_override("default_color", Color.darkgreen)
	
	money_message_timer = money_message_timeout
	
	if money <= 0:
		lose()
	

func add_message(text: String) -> void:
	var message: Control = helper_message_scene.instance()
	helper_messages.add_child(message)
	message.text = text
	helper_message_timers.push_back({
		"value": 10.0,
		"child": message
	})
	

func lose():
	get_tree().paused = true
	game_over_modal.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func _on_Retry_mouse_entered():
	retry_label.get_font("normal_font").outline_color = Color.gray


func _on_Retry_mouse_exited():
	retry_label.get_font("normal_font").outline_color = Color.black


func _on_Retry_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index & BUTTON_LEFT:
			get_tree().paused = false
			get_tree().change_scene("res://Scenes/Game.tscn")
	

func _on_Exit_mouse_entered():
	exit_label.get_font("normal_font").outline_color = Color.gray
	

func _on_Exit_mouse_exited():
	exit_label.get_font("normal_font").outline_color = Color.black
	

func _on_Exit_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index & BUTTON_LEFT:
			get_tree().quit()
	
