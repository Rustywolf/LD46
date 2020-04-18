extends Node

const WIDTH := 8;
const DEPTH := 5;

const spaces := [];

func _ready():
	for x in range(WIDTH):
		spaces[x] = []
		for z in range(DEPTH):
			spaces[x][z] = null
			

func put(x: int, z: int, item: Node):
	assert(spaces[x][z] == null)
	
	spaces[x][z] = item
	item.get_parent().remove_child(item)
	add_child(item)
	item.transform.origin = Vector3(x + 0.5, 0, z + 0.5)
	
