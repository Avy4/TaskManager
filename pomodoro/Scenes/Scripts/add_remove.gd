extends Control

# Container to store tasks in
@export var task_holder : VBoxContainer

# Imports the SaveLoad class an creates a SaveLoad object
const SAVELOAD = preload("res://Scenes/Scripts/SaveLoad.gd")
var save_loader = SAVELOAD.SaveLoad.new()

# On new task button clicked instantiates a new task and adds that task to the task_holder
func _on_new_task_pressed() -> void:
	var task = save_loader.new_task.instantiate()
	task_holder.add_child(task)

# Removes all tasks that have the checkbutton clicked
func _on_remove_task_pressed() -> void:
	# Calls the tasks group method "clear_self"
	get_parent().get_tree().call_group("Tasks","clear_self")

# Saves the current tasks to the task_data.json
func _on_save_button_pressed() -> void:
	save_loader.save_data(task_holder)
