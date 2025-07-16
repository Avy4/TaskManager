extends Control

# Reference to the check_box inside of the task_object
@onready var check_box: CheckBox = $PanelContainer/HBoxContainer/CheckBox

# Called as part of a group call
func clear_self():
	# If the check_box is checked then it destroys itself
	if (check_box.button_pressed == true):
		queue_free()
