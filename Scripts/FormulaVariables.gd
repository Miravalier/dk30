extends Node

# Assumes key and value order is deterministic within the object.
var data = {}

func get(name: String):
	return data[name]

func set(name: String, value):
	data[name] = value

func has(name: String):
	return data.has(name)

func keys() -> PoolStringArray:
	return data.keys()

func values():
	return data.values()
