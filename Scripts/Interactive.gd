extends Spatial
class_name Interactive

onready var box: Spatial = $"CSGBox"
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
	

func render_infront() -> void:
	box.material_override.flags_no_depth_test = true
	outline_material.flags_no_depth_test = true
	

func render_normal() -> void:
	box.material_override.flags_no_depth_test = false
	outline_material.flags_no_depth_test = false
