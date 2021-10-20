extends Node

var data = {}

func get(name):
	return data[name]

func set(name, value):
	data[name] = value

func has(name):
	return data.has(name)

func keys():
	return data.keys()

func values():
	return data.values()
