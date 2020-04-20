extends Plant

onready var tex_healthy = \
	preload("res://Objects/Textures/Plant_healthy/SM_plant_Plant_healthy_BaseColor.png")
onready var tex_unhealthy_leaves = \
	preload("res://Objects/Textures/Plant_healthy_redleaves/" + \
	"SM_plant_Plant_Alive_readleaves_BaseColor.png")
onready var tex_sick = \
	preload("res://Objects/Textures/Plant_sick/SM_plant_Plant_sick_BaseColor.png")
onready var tex_dead = \
	preload("res://Objects/Textures/Plant_dead/SM_plant_Plant_dead_BaseColor.png")

func _init().("Plant"):
	lifetime = rand_range(75.0, 120.0)
	water_lifetime = rand_range(30.0, 60.0)
	fertilization_lifetime = rand_range(60.0, 150.0)
	min_unhealthy_leaves_time = 30.0
	max_unhealthy_leaves_time = 100.0
	unhealthy_time_before_disease = 10.0
	

func _ready():
	health_states = [
		tex_healthy,
		tex_unhealthy_leaves,
		tex_sick,
		tex_dead
	]
	._ready()

func tick(delta) -> void:
	age += (delta / lifetime) * health
	water -= delta / water_lifetime
	fertilization -= delta / fertilization_lifetime
	sun -= 0 # To do
	
	if not diseased and not had_random_disease:
		var chance = 100000
		if transform.origin.y < 1:
			chance /= 5
		
		var diseased_neighbours = get_diseased_neighbours()
		if diseased_neighbours > 0:
			chance /= 50 * diseased_neighbours
			
		if (randi() % chance) == 0:
			set_diseased(true)
			had_random_disease = true
			
	.tick(delta)
	
	if diseased:
		health -= delta / 30.0
	elif water < .25:
		health -= delta / 20.0
	elif water < .5 or fertilization <= 0.0:
		pass # no health regen
	else:
		health += delta / 20
		
	health = min(max(health, 0), 1)
	

func get_diseased_neighbours() -> int:
	var count := 0
	var x := int(transform.origin.x)
	var z := int(transform.origin.z)
	
	if not get_parent().is_in_group("room"):
		return 0;
	
	if not get_parent().empty(x-1, z):
		if get_parent().get_plant(x-1, z).diseased:
			count += 1
	
	if not get_parent().empty(x+1, z):
		if get_parent().get_plant(x+1, z).diseased:
			count += 1
	
	if not get_parent().empty(x, z-1):
		if get_parent().get_plant(x, z-1).diseased:
			count += 1
	
	if not get_parent().empty(x, z+1):
		if get_parent().get_plant(x, z+1).diseased:
			count += 1
	
	return count
	

func messages() -> Array:
	var messages := []
	
	if int(transform.origin.x) == 1 and int(transform.origin.z) == 1:
		messages.push_back({
			"value": -3.0,
			"message": "Move me to the tables"
		})
		
	
	if diseased:
		messages.push_back({
			"value": -2.0,
			"message": "aCHOO"
		})
	
	if get_diseased_neighbours() > 0:
		messages.push_back({
			"value": -1.5,
			"message": "Get me AWAY from them"
		})
	
	if unhealthy_leaves:
		messages.push_back({
			"value": -1.0,
			"message": "I could use a trimming"
		})
	
	if water < .25:
		messages.push_back({
			"value": .25,
			"message": "So... thirsty..."
		})
	
	if fertilization <= 0:
		messages.push_back({
			"value": 0.35,
			"message": "I think I need some fertilizer?"
		})
	
	elif water < .5:
		messages.push_back({
			"value": .50,
			"message": "Could I get some water?"
		})
		
		
	return messages
