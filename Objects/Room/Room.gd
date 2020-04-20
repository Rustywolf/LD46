extends Spatial

const sunflower_scene: PackedScene = preload("res://Objects/Plants/Sunflower/Sunflower.tscn")

const WIDTH := 8;
const DEPTH := 5;

var spaces := [];
const raised := [
	[2, 0, 1, 1, 1, 1, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 1, 1, 1, 1, 0, 1],
	[0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 1, 1, 1, 1, 0, 1],
];

const start_spawnrate := 30.0
const max_spawnrate := 8.0
var spawnrate := start_spawnrate
var spawnrate_timer := 20.0
var plant_count := 0
var first_spawn = true

func _ready():
	plant_count = 0
	spawnrate = start_spawnrate
	spaces = []
	for z in range(DEPTH):
		spaces.push_back([])
		for x in range(WIDTH):
			spaces[z].push_back(null)
			
	place(8, 2, $"WateringCan")
	place(8, 3, $"GardeningShears")
	place(8, 4, $"Fertilizer")
	place(8, 5, $"Medicine")
	
	add_plant(3, 1)
	add_plant(4, 1)
	add_plant(5, 1)
	add_plant(6, 1)
	
	get_plant(3, 1).age -= 1
	get_plant(4, 1).age -= .66
	get_plant(5, 1).age -= .33
	

func _process(delta):
	spawnrate_timer -= delta
	if spawnrate_timer <= 0:
		if add_plant():
			if first_spawn:
				$"../CanvasLayer/UI".add_message("You'll want to move the plant in the corner")
				$"../CanvasLayer/UI".add_message("We can't receive new ones until you do", 2)
				first_spawn = false
			else:
				$"../CanvasLayer/UI".add_message("New plant coming in!")
		spawnrate -= 2
		spawnrate = max(spawnrate, max_spawnrate)
		spawnrate_timer = spawnrate

func get_plant(x: int, z: int):
	return spaces[z-1][x-1]
	

func add_plant(x: int = 1, z: int = 1) -> bool:
	if (!empty(x, z)):
		return false
		
	if plant_count >= 12:
		return false
	
	var plant := sunflower_scene.instance()
	place(x, z, plant, true)
	plant_count += 1
	return true
	

func empty(x: int, z: int) -> bool:
	if x < 1 or z < 1 or x > WIDTH or z > DEPTH:
		return true
	return spaces[z-1][x-1] == null
	

func raised(x: int, z: int) -> bool:
	if x < 1 or z < 1 or x > WIDTH or z > DEPTH:
		return false
	return raised[z-1][x-1] > 0
	

func place(x: int, z: int, item: Node, force: bool = false) -> bool:
	if x < 1 or z < 1 or x > WIDTH or z > DEPTH:
		return false
		
	if raised[z-1][x-1] == 2 and not force:
		return false
		
	spaces[z-1][x-1] = item
	if (item.get_parent()):
		item.get_parent().remove_child(item)
	add_child(item)
	var y := .9 if raised[z-1][x-1] else 0.05
	item.transform.origin = Vector3(x + 0.5, y, z + 0.5)
	return true
	

func pickup(x: int, z: int) -> void:
	assert(spaces[z-1][x-1] != null)
	assert(x >= 1 and x <= WIDTH)
	assert(z >= 1 and z <= DEPTH)
	spaces[z-1][x-1] = null
