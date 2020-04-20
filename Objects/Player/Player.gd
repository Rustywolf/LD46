extends KinematicBody

const SPEED : float = 2.5
const MOUSE_SENSITIVITY : float = 0.005
var HELD_KEYS : Dictionary = {
	"forward": false,
	"backward": false,
	"left": false,
	"right": false,
}

onready var UI: Control = $"../../CanvasLayer/UI"
onready var audio: Control = $"../../CanvasLayer/UI/Audio"
onready var camera: Camera = $"Camera"
onready var raycast: RayCast = $"Camera/RayCast"
onready var room: Spatial = $".."
onready var selector: Spatial = $"../Selector"
onready var viewport: Viewport = $"ViewportContainer/Viewport"
onready var viewport_camera: Camera = $"ViewportContainer/Viewport/Camera"

var velocity := Vector3.ZERO
var looking_at: Spatial;
var looking_at_spot := Vector3.ZERO;
var equipped: Spatial;
var run_equip := false;
var run_place := false;
var run_interact := false;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	HELD_KEYS = {
		"forward": false,
		"backward": false,
		"left": false,
		"right": false,
	}
	
	velocity = Vector3.ZERO
	looking_at = null
	looking_at_spot = Vector3.ZERO
	equipped = null
	run_equip = false
	run_place = false
	run_interact = false
	

func _physics_process(delta):
	velocity = Vector3.ZERO;
	
	if HELD_KEYS.forward:
		velocity += global_transform.basis.z * -SPEED
	
	if HELD_KEYS.backward:
		velocity += global_transform.basis.z * SPEED

	if HELD_KEYS.left:
		velocity += global_transform.basis.x * -SPEED

	if HELD_KEYS.right:
		velocity += global_transform.basis.x * SPEED
	
	move_and_collide(velocity * delta)
	viewport_camera.transform = camera.transform.translated(Vector3(1000, 0, 0))
	
	if run_equip:
		equip()
		run_equip = false
		
	if run_place:
		place()
		run_place = false
		
	if run_interact:
		interact()
		run_interact = false
	
	raycast.force_raycast_update()
	var collider: Spatial = raycast.get_collider()
	
	if collider != null and collider.is_in_group("interactive"):
		if collider != looking_at:
			if looking_at != null:
				looking_at.hide_hover()
			collider.show_hover()
			looking_at = collider
	elif looking_at != null:
		looking_at.hide_hover()
		looking_at = null
		
		
	if collider != null and collider.is_in_group("spot") and equipped != null:
		var collision_point = raycast.get_collision_point()
		if collider.is_in_group("floor"):
			looking_at_spot = Vector3(floor(collision_point.x), 0, floor(collision_point.z))
		elif collider.is_in_group("workbench"):
			var collision_normal = raycast.get_collision_normal()
			var target_point = collision_point - (collision_normal.normalized() / 2)
			looking_at_spot = Vector3(floor(target_point.x), .9, floor(target_point.z))
			if not room.raised(looking_at_spot.x, looking_at_spot.z):
				looking_at_spot.y = 0
			
		if (looking_at_spot.x != 1 || looking_at_spot.z != 1) and \
			room.empty(looking_at_spot.x, looking_at_spot.z):
			selector.visible = true
			selector.transform.origin = looking_at_spot + Vector3(0.5, 0, 0.5)
		else:
			selector.visible = false
		
	else:
		looking_at_spot = Vector3.ZERO
		selector.visible = false
		
	var new_text: String = ""
	if looking_at and not equipped:
		if looking_at.is_in_group("tool"):
			new_text = "Pickup %s" % looking_at.display_name
			
		elif looking_at.is_in_group("plant") or looking_at.is_in_group("stem"):
			var plant = looking_at
			if looking_at.is_in_group("stem"):
				plant = plant.get_parent()
			
			if plant.health <= 0:
				new_text = "Remove dead %s" % plant.display_name
			elif plant.age >= 1:
				new_text = "Sell %s" % plant.display_name
			else:
				new_text = "Pickup %s" % plant.display_name
				
	elif looking_at and equipped:
		if equipped.is_in_group("tool") and \
			(looking_at.is_in_group("stem") or looking_at.is_in_group("plant")):
			var plant = looking_at
			if looking_at.is_in_group("stem"):
				plant = plant.get_parent()
			if plant.health <= 0:
				new_text = "Remove dead %s" % plant.display_name
			elif plant.age >= 1:
				new_text = "Sell %s" % plant.display_name
			else:
				var meets_requirements := false
				match(equipped.display_name):
					"Watering Can":
						meets_requirements = plant.water < 0.5
					"Gardening Shears":
						meets_requirements = plant.unhealthy_leaves
					"Medicine":
						meets_requirements = plant.diseased
					"Fertilizer":
						meets_requirements = true
						
				if meets_requirements:
					new_text = "Use %s on %s" % [
						equipped.display_name, 
						looking_at.display_name
					]
		elif equipped.is_in_group("tool") and looking_at.is_in_group("tool"):
			new_text = "Swap %s for %s" % [
				equipped.display_name, 
				looking_at.display_name
			]
	elif looking_at_spot != Vector3.ZERO and equipped and \
		room.empty(looking_at_spot.x, looking_at_spot.z):
		new_text = "Place %s" % equipped.display_name
		
	UI.pointer_text = new_text
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera.rotation += Vector3(-event.relative.y * MOUSE_SENSITIVITY, 0, 0)
		camera.rotation.x = min(max(camera.rotation.x, -PI/2), PI/2)
		rotation += Vector3(0, -event.relative.x * MOUSE_SENSITIVITY, 0)
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if equipped == null and looking_at != null:
				run_equip = true
			elif equipped != null and looking_at != null and \
				(looking_at.is_in_group("stem") || looking_at.is_in_group("plant")):
				var plant = looking_at
				if looking_at.is_in_group("stem"):
					plant = plant.get_parent()
				if plant.age >= 1 or plant.health <= 0:
					run_equip = true
				else:
					run_interact = true
			elif equipped != null and looking_at != null and \
				equipped.is_in_group("tool") and looking_at.is_in_group("tool"):
				run_equip = true
			elif equipped != null and looking_at_spot != Vector3.ZERO:
				run_place = true
	
	if event.is_action_pressed("move_forward"):
		HELD_KEYS.forward = true;
	elif event.is_action_released("move_forward"):
		HELD_KEYS.forward = false;
	
	if event.is_action_pressed("move_back"):
		HELD_KEYS.backward = true;
	elif event.is_action_released("move_back"):
		HELD_KEYS.backward = false;

	if event.is_action_pressed("move_left"):
		HELD_KEYS.left = true;
	elif event.is_action_released("move_left"):
		HELD_KEYS.left = false;

	if event.is_action_pressed("move_right"):
		HELD_KEYS.right = true;
	elif event.is_action_released("move_right"):
		HELD_KEYS.right = false;

	if event.is_action("ui_cancel"):
		get_tree().quit()
		

func place(item: Spatial = null) -> bool:
	assert(looking_at_spot != Vector3.ZERO)
	if item == null:
		assert(equipped != null)
		if not room.empty(looking_at_spot.x, looking_at_spot.z):
			return false
			
		if room.place(looking_at_spot.x, looking_at_spot.z, equipped):
			equipped.render_placed()
			equipped = null
			audio.play_place()
			return true
		else:
			return false
	else:
		if not room.empty(looking_at_spot.x, looking_at_spot.z):
			return false
		return room.place(looking_at_spot.x, looking_at_spot.z, item)
	

func equip() -> bool:
	if equipped:
		var x := int(looking_at.transform.origin.x)
		var z := int(looking_at.transform.origin.z)
		if looking_at.is_in_group("plant") or looking_at.is_in_group("stem"):
			var plant = looking_at
			if plant.is_in_group("stem"):
				plant = plant.get_parent()
				 
			if plant.age >= 1:
				room.pickup(
					int(plant.transform.origin.x), 
					int(plant.transform.origin.z)
				)
				plant.get_parent().remove_child(plant)
				plant.queue_free()
				var price = 200 + 400 * plant.health
				if plant.unhealthy_leaves:
					price -= 200
				if plant.diseased:
					price -= 200
				price = max(price, 100)
				UI.add_money("Sold %s" % plant.display_name, price)
				looking_at = null
				room.plant_count -= 1
				audio.play_place()
				return true
			elif plant.health <= 0:
				room.pickup(
					int(plant.transform.origin.x), 
					int(plant.transform.origin.z)
				)
				plant.get_parent().remove_child(plant)
				plant.queue_free()
				plant = null
				room.plant_count -= 1
				audio.play_place()
			else: 
				return false
		else:
			if x == 1 and z == 1:
				return false
				
			room.pickup(x, z)
			room.place(x, z, equipped)
			equipped.render_placed()
			equipped = looking_at
			looking_at = null
	else:
		var to_equip = looking_at
		if to_equip.is_in_group("stem"):
			to_equip = to_equip.get_parent()
			
		if not to_equip .is_in_group("plant") and \
			not to_equip .is_in_group("tool"):
				return false
				
		equipped = to_equip 
		looking_at.hide_hover()
		looking_at = null
			
		room.pickup(int(equipped.transform.origin.x), int(equipped.transform.origin.z))
		
		if equipped.is_in_group("plant"):
			if equipped.age >= 1:
				equipped.get_parent().remove_child(equipped)
				equipped.queue_free()
				var price = 200 + 400 * equipped.health
				if equipped.unhealthy_leaves:
					price -= 200
				if equipped.diseased:
					price -= 200
				price = max(price, 100)
				UI.add_money("Sold %s" % equipped.display_name, price)
				equipped = null
				room.plant_count -= 1
				audio.play_place()
				return true
			elif equipped.health <= 0:
				equipped.get_parent().remove_child(equipped)
				equipped.queue_free()
				equipped = null
				room.plant_count -= 1
				audio.play_place()
				return true
		
	equipped.hide_hover()
	equipped.render_pickedup()
	equipped.get_parent().remove_child(equipped)
	viewport_camera.add_child(equipped)
	equipped.transform.origin = Vector3(+0.5, -0.5, -1)
	audio.play_place()
	return true
	

func interact() -> void:
	if equipped.is_in_group("tool"):
		var plant = looking_at
		if looking_at.is_in_group("stem"):
			plant = plant.get_parent()
			
		if plant.use_tool(equipped):
			match(equipped.display_name):
				"Watering Can":
					audio.play_watering_can()
				"Gardening Shears":
					audio.play_shears()
				"Medicine":
					audio.play_medicine()
				"Fertilizer":
					audio.play_fertilizer()
