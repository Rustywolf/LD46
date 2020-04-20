extends Interactive
class_name Plant


class Sorter:
	static func sort(a, b):
		return a.value < b.value
		

const MESSAGE_TIMEOUT := 20.0

onready var stem_seedling: PhysicsBody = $"Seedling"
onready var stem_growing: PhysicsBody = $"Growing"
onready var stem_mature: PhysicsBody = $"Mature"
onready var stem_active: PhysicsBody = stem_seedling
onready var textbox: Spatial = $"Textbox"

var lifetime := 0.0
var water_lifetime := 0.0
var min_unhealthy_leaves_time := 0.0
var max_unhealthy_leaves_time := 0.0
var unhealthy_time_before_disease := 0.0
var health_states := [Color.white, Color.lightgray, Color.darkgray, Color.black]

var unhealthy_leaves_timer := 0.0
var has_had_unhealthy := 0.0

var age := 0.0
var health := 1.0
var water := 1.0
var sun := 1.0
var fertilization := 0.0
var unhealthy_leaves := false
var diseased := false


func _init(_name: String).(_name):
	pass
	

func _ready():
	._ready()
	stem_active.get_node("Plant").material_override = \
		stem_active.get_node("Plant").material_override.duplicate()
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
		if abs(direction.x) > abs(direction.z):
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
	

func use_tool(item: Spatial) -> void:
	match(item.display_name):
		"Watering Can":
			water =  1.0
		"Gardening Shears":
			set_unhealthy_leaves(false)
		"Medicine":
			set_diseased(false)
		"Fertilizer":
			fertilization = 1.0
	

func set_active(stem) -> void:
	stem_active.visible = false
	stem_active.set_collision_layer_bit(14, false)
	stem.visible = true
	stem.set_collision_layer_bit(14, true)
	stem_active = stem
	stem_active.get_node("Plant").material_override = \
		stem_active.get_node("Plant").material_override.duplicate()
	set_health_state()
	

func set_diseased(value: bool) -> void:
	diseased = value
	set_health_state()
	

func set_unhealthy_leaves(value: bool) -> void:
	unhealthy_leaves = value
	if not value:
		set_leaves_timer()
	set_health_state()
	

func set_health_state() -> void:
	var stem_material = stem_active.get_node("Plant").material_override
	if health <= 0:
		stem_material.albedo_color = health_states[3]
	if diseased:
		stem_material.albedo_color = health_states[2]
	elif unhealthy_leaves:
		stem_material.albedo_color = health_states[1]
	else:
		stem_material.albedo_color = health_states[0]
		

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
	else:
		textbox.text = ""
