extends Spatial

const WIDTH := 8;
const DEPTH := 5;

const spaces := [];
const raised := [
	[2, 0, 1, 1, 1, 1, 0, 0],
	[0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 1, 1, 1, 1, 0, 1],
	[0, 0, 0, 0, 0, 0, 0, 1],
	[0, 0, 1, 1, 1, 1, 0, 1],
];


func _ready():
	for z in range(DEPTH):
		spaces.push_back([])
		for x in range(WIDTH):
			spaces[z].push_back(null)
			
	place(2, 1, $"WaterCan")
	

func place(x: int, z: int, item: Node) -> bool:
	assert(spaces[z-1][x-1] == null)
	assert(x >= 1 and x <= WIDTH)
	assert(z >= 1 and z <= DEPTH)
	if raised[z-1][x-1] == 2:
		return false
		
	spaces[z-1][x-1] = item
	item.get_parent().remove_child(item)
	add_child(item)
	var y := 1.1 if raised[z-1][x-1] else 0.1
	item.transform.origin = Vector3(x + 0.5, y, z + 0.5)
	return true
	

func pickup(x: int, z: int) -> void:
	assert(spaces[z-1][x-1] != null)
	assert(x >= 1 and x <= WIDTH)
	assert(z >= 1 and z <= DEPTH)
	spaces[z-1][x-1] = null
