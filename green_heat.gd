extends Node
class_name GreenHeat

signal input_received(input: GreenHeatInput) ## an exposed signal for detecting any inputs

@export var channel_name : String = "": ## this is the channel name
	set(value):
		if (channel_name.length() != 0 && enabled): return
		channel_name = value

@export var enabled := false: ## defines if the process should be running
	set(value):
		_debug_print("set enabled: %s" % value)
		if value:
			if is_node_ready():
				value = connect_as("")
		else:
			_disconnect_from_server()
		_enabled = value
	get():
		return _enabled && !Engine.is_editor_hint()
		
@export var minify_data : bool = true: # ask for a reduced packets data
	set(value):
		if (enabled): return
		minify_data = value

var _debug = false
var _enabled: bool
var _processed_count: int = 0 # for debug aestethics
var _ws := WebSocketPeer.new()

func _debug_print(text: String):
	if _debug:
		print("[GH_%s] %s" % [get_instance_id(), text])

func _ready():
	if !enabled: return
	_debug_print("connecting to GreenHeat on ready")
	_enabled = connect_as("")

# connect to GreenHeat servers as the channel
func connect_as(_channel_name: String):
	if _channel_name.length() > 0:
		channel_name = _channel_name

	if channel_name.length() == 0:
		printerr("can't connect to GreenHeat with an empty channel name")
		return false

	if _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		printerr("GreenHeat server is connected already")
		return false

	var url = _get_ws_url()
	_debug_print("connecting to %s.." % url)
	_ws.connect_to_url(url)

	return true
	
# connect to GreenHeat servers as the channel
func _disconnect_from_server():
	if _ws.get_ready_state() != _ws.STATE_CLOSED:
		var url = _get_ws_url()
		_debug_print("hard disconnect from %s" % url)
		_ws.close()

func _get_ws_url():
	var url = "wss://heat.prod.kr/%s" % channel_name
	if minify_data == true:
		url += "?minify"
	return url

func _process(delta: float) -> void:
	if !enabled:
		return
	
	_ws.poll()
	_processed_count += 1

	var packet_count: int
	while true:
		packet_count = _ws.get_available_packet_count()
		if packet_count <= 0:
			break

		var raw = _ws.get_packet().get_string_from_utf8()
		# _debug_print("%s_%s: %s" % [_processed_count, packet_count, raw]) # spammy

		var packet = JSON.parse_string(raw)
		if packet == null: continue

		var input = GreenHeatInput.new()
		input._packet = packet
		input.is_minified = minify_data
		input_received.emit(input)