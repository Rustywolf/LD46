extends Spatial

onready var start_text: RichTextLabel = $"CanvasLayer/StartText"


func _on_StartText_mouse_entered():
	start_text.get_font("normal_font").outline_color = Color.gray


func _on_StartText_mouse_exited():
	start_text.get_font("normal_font").outline_color = Color.black
	

func _on_StartText_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index & BUTTON_LEFT:
			get_tree().change_scene("res://Scenes/Game.tscn")
