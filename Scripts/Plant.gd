extends Interactive
class_name Plant


class Sorter:
	static func sort(a, b):
		return a.value < b.value
		

const MESSAGE_TIMEOUT := 20.0

onready var UI: Control = $"../../CanvasLayer/UI"
onready var stem_seedling: PhysicsBody = $"Seedling"
onready var stem_growing: PhysicsBody = $"Growing"
onready var stem_mature: PhysicsBody = $"Mature"
onready var stem_active: PhysicsBody = stem_seedling
onready var textbox: Spatial = $"Textbox"

var lifetime := 0.0
var water_lifetime := 0.0
var fertilization_lifetime := 0.0
var min_unhealthy_leaves_time := 0.0
var max_unhealthy_leaves_time := 0.0
var unhealthy_time_before_disease := 0.0
var health_states := []

var unhealthy_leaves_timer := 0.0
var has_had_unhealthy := 0.0

var age := 0.0
var health := 1.0
var water := 1.0
var sun := 1.0
var fertilization := 0.3
var unhealthy_leaves := false
var had_random_disease := false


func _init(_name: String).(_name):
	pass
	

func _ready():
	._ready()
	stem_active.get_node("Plant").material_override = \
		stem_active.get_node("Plant").material_override.duplicate()
	stem_active.get_node("Outline").material_override = \
		stem_active.get_node("Outline").material_override.duplicate()
	$"Outline".material_override = $"Outline".material_override.duplicate()
	
	add_to_group("plant")
	set_leaves_timer()
	

func set_leaves_timer():
	unhealthy_leaves_timer = \
		rand_range(min_unhealthy_leaves_time, max_unhealthy_leaves_time)
		

func tick(delta: float) -> void:
	if unhealthy_leaves:
		has_had_unhealthy += delta
		if has_had_unhealthy > unhealthy_time_before_disease and not diseased:
			set_diseased(true)
	else:
		has_had_unhealthy = 0.0
	
	unhealthy_leaves_timer -= delta;
	if unhealthy_leaves_timer <= 0:
		set_unhealthy_leaves(true)
		
	if get_parent().is_in_group("room"):
		var player = $"../Player"
		var direction: Vector3 = \
			(player.global_transform.origin - global_transform.origin)
		if abs(direction.x) > abs(direction.z) * 3:
			if direction.x < 0:
				textbox.rotation.y = -PI/2
			else:
				textbox.rotation.y = PI/2
		else:
			if direction.z < 0:
				textbox.rotation.y = -PI
			else:
				textbox.rotation.y = 0
	else:
		textbox.rotation.y = 0

func messages() -> Array:
	return []
	

func use_tool(item: Spatial) -> bool:
	match(item.display_name):
		"Watering Can":
			if water < .5:
				water =  1.0
				return true
		"Gardening Shears":
			if unhealthy_leaves:
				set_unhealthy_leaves(false)
				return true
		"Medicine":
			if diseased:
				set_diseased(false)
				return true
		"Fertilizer":
			fertilization = 1.0
			return true
	return false
	

func set_active(stem) -> void:
	stem_active.visible = false
	stem_active.set_collision_layer_bit(14, false)
	stem.visible = true
	stem.set_collision_layer_bit(14, true)
	stem_active = stem
	stem_active.get_node("Plant").material_override = \
		stem_active.get_node("Plant").material_override.duplicate()
	stem_active.get_node("Outline").material_override = \
		stem_active.get_node("Outline").material_override.duplicate()
	set_health_state()
	

func set_diseased(value: bool) -> void:
	diseased = value
	if diseased:
		UI.alert_diseased()
	if unhealthy_leaves:
		set_unhealthy_leaves(false)
	set_health_state()
	

func set_unhealthy_leaves(value: bool) -> void:
	unhealthy_leaves = value
	if not value:
		set_leaves_timer()
	set_health_state()
	

func set_health_state() -> void:
	var next_state = null;
	if health <= 0:
		next_state = health_states[3]
	elif diseased:
		next_state = health_states[2]
	elif unhealthy_leaves:
		next_state = health_states[1]
	else:
		next_state = health_states[0]
	
	stem_active.get_node("Plant").material_override.albedo_texture = next_state

func _process(delta: float) -> void:
	var alive := health > 0
	if stem_active != stem_mature and alive:
		tick(delta)
	
	if alive and health <= 0:
		set_health_state()
	
	if age > 1:
		if stem_active != stem_mature:
			set_active(stem_mature)
	elif age > .33:
		if stem_active != stem_growing:
			set_active(stem_growing)
	
	var messages = messages()
	if stem_active != stem_mature and health > 0 and len(messages) > 0:
		messages.sort_custom(Sorter, "sort")
		var message = messages[0]
		textbox.text = message.message
	elif age >= 1:
		textbox.text = "You probably need to sell me now..."
	else:
		textbox.text = ""
