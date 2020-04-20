extends Spatial

onready var mesh: MeshInstance = $"MeshInstance"
onready var viewport: Viewport = $"MeshInstance/Viewport"
onready var label: RichTextLabel = $"MeshInstance/Viewport/MarginContainer/Label"
	
var text setget set_text

func _ready():
	var texture = viewport.get_texture()
	var material = SpatialMaterial.new()
	material.flags_transparent = true
	material.flags_unshaded = true
	material.albedo_texture = texture
	mesh.set_surface_material(0, material)


func set_text(text: String) -> void:
	label.text = text
	if text == "":
		visible = false
	else:
		visible = true
