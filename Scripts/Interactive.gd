extends Spatial
class_name Interactive

onready var outline: MeshInstance = $"Outline";
var display_name := "";
var initial_rotation := 0
var diseased := false

func _init(_name: String):
	assert(_name != "" and _name != null)
	display_name = _name;
	

func _ready():
	assert(outline != null)
	add_to_group("interactive")
	

func show_hover() -> void:
	outline.material_override.albedo_color = Color.white;
	

func hide_hover() -> void:
	outline.material_override.albedo_color = Color.black;
	

func get_pickedup_rotation() -> float:
	return 0.0
	

func render_pickedup() -> void:
	initial_rotation = rotation_degrees.y
	rotation_degrees.y = get_pickedup_rotation()
	

func render_placed() -> void:
	rotation_degrees.y = initial_rotation
