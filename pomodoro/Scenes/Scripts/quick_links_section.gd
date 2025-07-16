extends Panel

# Node imports
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var texture_rect: TextureRect = $StudyGraph
@onready var pomodoro_timer: Timer = %PomodoroTimer
@onready var time_added: Label = $TimeAdded
@onready var refresh: Button = $Refresh

# Constants to access the pixe.la API
const GRAPH_ID = "{ENTER_GRAPH_ID}"
const USERNAME = "{ENTER_USERNAME}"
const header : PackedStringArray = ["X-USER-TOKEN: {ENTER_USER_TOKEN}"]
var PIXELA_GRAPH_ENDPOINT = "https://pixe.la/v1/users/%s/graphs/%s" % [USERNAME, GRAPH_ID]

# Refreshes the graph on application start
func _ready() -> void:
	request_graph()

# GET Request to load a SVG of the current graph from pixe.la
# https://docs.pixe.la/entry/get-svg
func request_graph():
	# Cancels any ongoing request
	http_request.cancel_request()
	# Request URL
	var graph_url = PIXELA_GRAPH_ENDPOINT + "?%s&%s" % ["mode=short", "appearance=dark"]
	# Sends the request
	var _response = http_request.request(graph_url, [], HTTPClient.METHOD_GET)

# PUT Request to add 25 minutes on the current day to the graph
# https://docs.pixe.la/entry/put-graph
func add_data():
	# Cancels any ongoing request
	http_request.cancel_request()
	# Request URL
	var graph_url = PIXELA_GRAPH_ENDPOINT + "%s" % ["/add"]
	# Data sent to pixe.la
	var json_payload = JSON.stringify({"quantity" : "25"})
	# Sends the request
	var _response = http_request.request(graph_url, header, HTTPClient.METHOD_PUT, json_payload)

# DELETE request, resets the current days values. ONLY USED FOR TESTS
# https://docs.pixe.la/entry/delete-graph
func reset_data():
	# Cancels any ongoing request
	http_request.cancel_request()
	# Gets a dictionary of the current date in strings
	var curr_date = get_date()
	# Request URL
	var graph_url = PIXELA_GRAPH_ENDPOINT + "/%s%s%s" % [curr_date["year"], curr_date["month"], curr_date["day"]]
	# Sends the request
	var _response = http_request.request(graph_url, header, HTTPClient.METHOD_DELETE)

# Processes the response from the requests sent
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# Stores the type of data recieved from the API
	var data_type = headers[0].split(":")[1].strip_edges()
	# Checks if request was made and was a 0 (success)
	if result == HTTPRequest.RESULT_SUCCESS:
		# Checks if the reponse was a 200 (success)
		if response_code == HTTPClient.ResponseCode.RESPONSE_OK:
			# Image response
			if data_type == "image/svg+xml":
				# Creates a new image
				var image = Image.new()
				# Loads the SVG from the body buffer
				var _error = image.load_svg_from_buffer(body)
				# Creates the texture and sets the texture_rect to the graph
				var texture = ImageTexture.create_from_image(image)
				texture_rect.texture = texture
		else:
			print("Response code: " + str(response_code))
			# Error 503 means that an arbritary failure occured. Just call the function again.
			# "If the response body contains "isRejected":true, it indicates that the request was rejected 25% of the time. 
			# In this case, the request can be retried until it succeeds."
			if response_code == 503:
				add_data()
	else:
		print("Result: " + str(result))

# Signal occurring when the refresh button is clicked
func _on_refresh_pressed() -> void:
	# Visual confirmation of 25 minutes being added
	time_added.text = "+25 Minutes"
	# Calls the function that actually calls the API to add 25 minutes 
	add_data()
	# Waits till add_data goes through
	await Signal(http_request, 'request_completed')
	await get_tree().create_timer(1).timeout
	# Requests graph after giving time for data to be added
	request_graph()
	# Resets visual confirmation text
	time_added.text = "" 

# Helper method to get the date
func get_date():
	# Gets the current date in a dictionary as an int
	var curr_date = Time.get_datetime_dict_from_system(false)
	# Converts the day to a string and pads with 0 if needed
	if str(curr_date["day"]).length() == 1:
		curr_date["day"] = "0" + str(curr_date["day"])
	# Converts the month to a string and pads with 0 if needed
	if str(curr_date["month"]).length() == 1:
		curr_date["month"] = "0" + str(curr_date["month"])
	return curr_date

# Enables the refresh button only after 25 minutes have passed
# It will be enabled during the 5 and 30 minute breaks though
func _on_pomodoro_timer_timeout() -> void:
	refresh.disabled = false

# Disables the refresh button while timer is counting down
func _on_start_pressed() -> void:
	refresh.disabled = true
