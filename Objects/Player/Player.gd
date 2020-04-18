extends KinematicBody

const SPEED : float = 2.5
const MOUSE_SENSITIVITY : float = 0.01
const HELD_KEYS : Dictionary = {
	"forward": false,
	"backward": false,
	"left": false,
	"right": false,
}

onready var camera: Camera = $"Camera"
onready var raycast: RayCast = $"Camera/RayCast"
onready var room: Spatial = $".."
onready var selector: Spatial = $"../Selector"
var velocity := Vector3.ZERO
var looking_at: Spatial;
var looking_at_spot := Vector3.ZERO;
var equipped: Spatial;
var run_equip := false;
var run_place := false;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

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
	
	if run_equip:
		equip()
		run_equip = false
		
	if run_place:
		place()
		run_place = false
	
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
			looking_at_spot = Vector3(floor(target_point.x), 1, floor(target_point.z))
			
		if (looking_at_spot.x != 1 || looking_at_spot.z != 1):
			selector.visible = true
			selector.transform.origin = looking_at_spot + Vector3(0.5, 0, 0.5)
		else:
			selector.visible = false
		
	else:
		looking_at_spot = Vector3.ZERO
		selector.visible = false
	

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera.rotation += Vector3(-event.relative.y * MOUSE_SENSITIVITY, 0, 0)
		camera.rotation.x = min(max(camera.rotation.x, -PI/2), PI/2)
		rotation += Vector3(0, -event.relative.x * MOUSE_SENSITIVITY, 0)
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if equipped == null and looking_at != null:
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
		if room.place(looking_at_spot.x, looking_at_spot.z, equipped):
			equipped.render_normal()
			equipped = null
			return true
		else:
			return false
	else:
		return room.place(looking_at_spot.x, looking_at_spot.z, item)
	

func equip(item: Spatial = null) -> void:
	if equipped:
		assert(item == null)
		var x := int(looking_at.transform.origin.x)
		var z := int(looking_at.transform.origin.z)
		if x == 1 and z == 1:
			return
			
		room.pickup(x, z)
		assert(room.place(x, z, equipped))
		equipped.render_normal()
		equipped = looking_at
		looking_at = null
	else:
		if item:
			equipped = item
		else:
			equipped = looking_at
			looking_at = null
		room.pickup(int(equipped.transform.origin.x), int(equipped.transform.origin.z))
		
	equipped.hide_hover()
	equipped.render_infront()
	equipped.get_parent().remove_child(equipped)
	camera.add_child(equipped)
	equipped.transform.origin = Vector3(+0.5, -0.5, -1)
