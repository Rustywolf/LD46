extends Node

onready var bag_pour: AudioStreamPlayer = $"BagPour"
onready var watering_can: AudioStreamPlayer = $"WateringCan"
onready var garden_shears: AudioStreamPlayer = $"GardenShears"
onready var place: AudioStreamPlayer = $"Place"
onready var ping: AudioStreamPlayer = $"Ping"

func play_medicine():
	bag_pour.playing = true
	

func play_fertilizer():
	bag_pour.playing = true
	

func play_shears():
	garden_shears.playing = true
	

func play_watering_can():
	watering_can.playing = true
	

func play_place():
	place.playing = true
	

func play_ping():
	ping.playing = true
	

func _on_BagPour_finished():
	bag_pour.playing = false


func _on_WateringCan_finished():
	watering_can.playing = false


func _on_GardenShears_finished():
	garden_shears.playing = false


func _on_Place_finished():
	place.playing = false


func _on_AudioStreamPlayer_finished():
	pass # Replace with function body.
