extends Plant

func _init().("Sunflower"):
	lifetime = 60.0
	water_lifetime = 20.0
	min_unhealthy_leaves_time = 25.0
	max_unhealthy_leaves_time = 45.0
	unhealthy_time_before_disease = 10.0
	health_states = [Color("7fbb13"), Color("#bb9113"), Color("#695f55"), Color.black]
	

func tick(delta) -> void:
	age += (delta / lifetime) * health
	water -= delta / water_lifetime
	fertilization -= 0 # Only needs init fert
	sun -= 0 # To do
	
	.tick(delta)
	
	if diseased:
		health -= delta / 10
	elif water < .25:
		health -= delta / 20
	elif water < .5 or fertilization <= 0.0:
		pass # no health regen
	else:
		health += delta / 20
		
	health = min(max(health, 0), 1)
	

func messages() -> Array:
	var messages := []
	
	if diseased:
		messages.push_back({
			"value": -2.0,
			"message": "Diseased"
		})
	
	if unhealthy_leaves:
		messages.push_back({
			"value": -1.0,
			"message": "Unhealthy Leaves"
		})
	
	if water < .25:
		messages.push_back({
			"value": .25,
			"message": "Water 25%"
		})
	elif water < .5:
		messages.push_back({
			"value": .50,
			"message": "Water 50%"
		})
		
		
	return messages
