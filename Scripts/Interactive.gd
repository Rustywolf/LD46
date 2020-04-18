extends Spatial
class_name Interactive

onready var outline: MeshInstance = $"Outline";
var outline_material: Material;
var display_name := "";


func _init(_name: String):
	assert(_name != "" and _name != null)
	display_name = _name;
	

func _ready():
	assert(outline != null)
	outline_material = outline.get_surface_material(0).duplicate();
	outline.set_surface_material(0, outline_material);
	
	add_to_group("interactive")
	

func show_hover() -> void:
	outline_material.albedo_color = Color.white;
	

func hide_hover() -> void:
	outline_material.albedo_color = Color.black;
	
	
