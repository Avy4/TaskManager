# Class that handles saving and loading of task data through the task_data.json file
class SaveLoad:
	# Paths to the task_data.json file and the text property of a new_task object
	# need to use user://task_data.json instead of res:// because the actual files in the 
	# application aren't writable to when its running
	const file_path = "user://task_data.json"
	const text_path = "PanelContainer/HBoxContainer/Text"
	
	# new_task scene that can be instantiated
	var new_task : PackedScene = preload("res://Scenes/Objects/task_object.tscn")
	# Dict that task_data will be added to and stored from
	static var task_data = {
		"Task_Text" : []
	}
	
	# Saves data from the _task_holder container
	func save_data(_task_holder : VBoxContainer):
		# Reset the tasks
		task_data["Task_Text"] = []
		# If the file doesnt exist it is created
		var data_file = FileAccess.open(file_path, FileAccess.WRITE)
		# Iterates through an array of the all the tasks
		for child in _task_holder.get_children():
			# Checks if the child is a task (and not the first child which is the add_remove obj)
			if "Tasks" in child.get_groups():
				# Appends the data to the "Task_Text" array
				task_data["Task_Text"].append(child.get_node(text_path).text)
		# Converts the dict into a JSON format and stores it into the data file
		data_file.store_line(JSON.stringify(task_data, "\t"))
	
	# Loads data from the JSON into the application
	func load_data(_task_holder : VBoxContainer):
		# Can only load data if the file exists
		if FileAccess.file_exists(file_path):
			# Opens the file for reading
			var data_file = FileAccess.open(file_path, FileAccess.READ)
			# Makes sure that the file is not empty
			if data_file.get_length() != 0:
				# Gets the text from the json file as a dictionary
				var parsed_text = JSON.parse_string(data_file.get_as_text())
				# Makes sure the dictionary exists
				if parsed_text != null:
					# Iterates through the "Task_Text"
					for task_text in parsed_text["Task_Text"]:
						# Creates a new task
						var task = new_task.instantiate()
						# Sets the text of the new task
						task.get_node(text_path).text = task_text
						# Adds the new task to the task_holder
						_task_holder.add_child(task)
