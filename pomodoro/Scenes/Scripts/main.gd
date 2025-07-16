extends Node2D

# Task holder reference to load data into
@onready var task_holder: VBoxContainer = $MainCanvas/Sections/TasksSection/TaskScroller/TaskHolder

# Imports the SaveLoad class
const SAVELOAD = preload("res://Scenes/Scripts/SaveLoad.gd")

# Runs on application open
func _ready() -> void:
	# Only refreshes the application if needed
	OS.low_processor_usage_mode = true
	# Creates a SAVELOAD object and calls the load function
	var save_loader = SAVELOAD.SaveLoad.new()
	save_loader.load_data(task_holder)
