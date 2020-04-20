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

const start_spawnrate := 50.0
const max_spawnrate := 30.0
var spawnrate := start_spawnrate
var spawnrate_timer := spawnrate
var plant_count := 0

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
	
	add_plant()
	

func _process(delta):
	spawnrate_timer -= delta
	if spawnrate_timer <= 0:
		add_plant()
		spawnrate -= 1
		spawnrate = max(spawnrate, max_spawnrate)
		spawnrate_timer = spawnrate
		

func add_plant() -> bool:
	if (!empty(1, 1)):
		return false
		
	if plant_count >= 12:
		return false
	
	var plant := sunflower_scene.instance()
	place(1, 1, plant, true)
	plant_count += 1
	return true
	

func empty(x: int, z: int) -> bool:
	if x < 1 or z < 1 or x > WIDTH or z > DEPTH:
		return false
	return spaces[z-1][x-1] == null
	

func place(x: int, z: int, item: Node, force: bool = false) -> bool:
	assert(spaces[z-1][x-1] == null)
	assert(x >= 1 and x <= WIDTH)
	assert(z >= 1 and z <= DEPTH)
	if raised[z-1][x-1] == 2 and not force:
		return false
		
	spaces[z-1][x-1] = item
	if (item.get_parent()):
		item.get_parent().remove_child(item)
	add_child(item)
	var y := 1.05 if raised[z-1][x-1] else 0.05
	item.transform.origin = Vector3(x + 0.5, y, z + 0.5)
	return true
	

func pickup(x: int, z: int) -> void:
	assert(spaces[z-1][x-1] != null)
	assert(x >= 1 and x <= WIDTH)
	assert(z >= 1 and z <= DEPTH)
	spaces[z-1][x-1] = null
