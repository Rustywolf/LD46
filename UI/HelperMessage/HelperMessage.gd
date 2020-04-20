extends Control


onready var text_label: RichTextLabel = $"MarginContainer/TextLabel"
var text: String = "" setget set_text


func _ready():
	text_label.bbcode_text = text
	

func set_text(value: String) -> void:
	text = value
	text_label.bbcode_text = text
