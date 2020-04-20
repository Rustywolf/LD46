extends Control

onready var pointer_text_label: RichTextLabel = $"PointerText"
var pointer_text := "" setget set_pointer_text

onready var money_total_label: RichTextLabel = $"Money/Entries/Total"
onready var money_entry_label: RichTextLabel = $"Money/Entries/Entry"
var money := 5000
var rent := 900
var max_rent := 1200
var rent_rate := 40.0
var rent_timer := rent_rate
var rent_increase_rate_min := 60.0
var rent_increase_rate_max := 90.0
var rent_increase_timer := 0.0
var money_message_timeout := 5.0
var money_message_timer := 0.0
var weeks_lasted := 0

onready var game_over_modal: RichTextLabel = $"GameOverModal"
onready var retry_label: RichTextLabel = $"GameOverModal/CenterContainer/VBoxContainer/Retry"
onready var exit_label: RichTextLabel = $"GameOverModal/CenterContainer/VBoxContainer/Exit"

onready var helper_message_scene: PackedScene = \
	preload("res://UI/HelperMessage/HelperMessage.tscn")
onready var helper_messages: VBoxContainer = $"HelperMessages"
var first_diseased = true
var helper_message_timers := []
var delayed_message_timers := [{
		"value": 2,
		"message": "Greetings! I'm your new assistant"
	}, {
		"value": 4,
		"message": "Please take good care of the plants"
	}, {
		"value": 6,
		"message": "They'll tell you if they need anything"
	}, {
		"value": 8,
		"message": "Start by fertilizing all new plants"
	}]

func _ready():
	set_rent_increase_timer()
	money_total_label.bbcode_text = "[right]Money: $%s[/right]" % max(money, 0)
	

func set_rent_increase_timer():
	rent_increase_timer = rand_range(rent_increase_rate_min, rent_increase_rate_max)
	

func _process(delta):
	rent_timer -= delta
	if rent_timer <= 0:
		add_money("Rent", -rent)
		rent_timer = rent_rate
		weeks_lasted += 1
	
	rent_increase_timer -= delta
	if rent_increase_timer <= 0 and rent < max_rent:
		rent += 50
		rent = min(rent, max_rent)
		set_rent_increase_timer()
		add_message("Curses! They've raised rent again! %s a week?!" % rent)
	
	money_message_timer -= delta
	if money_message_timer > 0:
		money_entry_label.visible = true
	else:
		money_entry_label.visible = false
	
	if len(delayed_message_timers) > 0:
		var filtered_delayed_message_timers := []
		for entry in delayed_message_timers:
			entry.value -= delta
			if entry.value <= 0:
				add_message(entry.message)
			else:
				filtered_delayed_message_timers.push_back(entry)
		delayed_message_timers = filtered_delayed_message_timers
	
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
	

func add_message(text: String, delay: float = 0) -> void:
	if delay > 0:
		delayed_message_timers.push_back({
			"value": delay,
			"message": text
		})
	else:
		var message: Control = helper_message_scene.instance()
		helper_messages.add_child(message)
		message.text = text
		helper_message_timers.push_back({
			"value": 15.0,
			"child": message
		})
		$"Audio".play_ping()
	

func alert_diseased():
	add_message("A plant is diseased. Quick! Medicine!")
	if first_diseased:
		add_message("Disease spreads quickly through plants", 2)
		first_diseased = false
	pass

func lose():
	get_tree().paused = true
	game_over_modal.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$"GameOverModal/CenterContainer/VBoxContainer/GameOver".bbcode_text = \
		"[center]Plants & Co\nlasted %s weeks[/center]" % weeks_lasted
	

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
	
