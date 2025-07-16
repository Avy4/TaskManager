extends Label

# References to nodes
@onready var pomodoro_timer: Timer = $PomodoroTimer
@onready var work_for: Label = %WorkFor

var cycles : int = 0
var started : bool = false

# Runs 60 times a second and sets on screen text to the time remaining
func _physics_process(_delta: float) -> void:
	var time_left = snappedi(pomodoro_timer.time_left, 1)
	# Cleans up how the text looks (00:00 instead of 0:0 when not started)
	if !started:
		text = "00:00"
	# Updates the text to the current time remaining
	else:
		text = str(time_left / 60) + ":" + str(time_left % 60)

# Runs on start button pressed signal
func _on_start_pressed() -> void:
	started = true
	# Setting the timer to work
	if cycles % 2 == 0:
		pomodoro_timer.start(1499)
		work_for.text = "Work for 25 Minutes!"
	# Setting the timer for long break
	elif cycles % 7 == 0:
		pomodoro_timer.start(1799)
		work_for.text = "Take a break for 30 Minutes!"
	# Setting the timer for short break
	else:
		pomodoro_timer.start(299)
		work_for.text = "Take a break for 5 Minutes!"

# Runs on the reset button pressed signal
func _on_reset_pressed() -> void:
	# Resets the entire pomodoro cycle
	cycles = 0
	# Stops the timer
	pomodoro_timer.stop()
	# Turns off text updates
	started = false
	work_for.text = "Hit start to begin!"

# Runs on the signal recieved when the timer finishes
func _on_pomodoro_timer_timeout() -> void:
	# Increases cycles
	cycles += 1
	# Turns off text updates
	started = false
	# Stops the timer
	pomodoro_timer.stop()
