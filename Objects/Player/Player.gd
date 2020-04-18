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
onready var selector: Spatial = $"../Selector"
var velocity := Vector3.ZERO
var looking_at: Spatial;
var looking_at_spot := Vector3.ZERO;
var equipped: Spatial;


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
	
	var collider: Spatial = raycast.get_collider()
	var parent: Spatial = null if collider == null else collider.get_parent()
	
	if parent != null and parent.is_in_group("interactive") and parent != looking_at:
		if looking_at != null:
			looking_at.hide_hover()
		parent.show_hover()
		looking_at = parent
	elif collider == null:
		if looking_at != null:
			looking_at.hide_hover()
			looking_at = null
		
	if collider != null and collider.is_in_group("spot") and equipped != null:
		var collision_point = raycast.get_collision_point()
		if collider.is_in_group("floor"):
			looking_at_spot = Vector3(floor(collision_point.x), 0, floor(collision_point.z))
			selector.visible = true
			selector.transform.origin = looking_at_spot + Vector3(0.5, 0, 0.5)
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
			if looking_at != null:
				equip(looking_at)
	
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

func equip(item: Spatial) -> void:
	if equipped:
		# handle swapping here
		pass
	else:
		equipped = looking_at
		equipped.hide_hover()
		equipped.get_parent().remove_child(equipped)
		camera.add_child(equipped)
		equipped.transform.origin = Vector3(+0.5, -0.5, -1)
