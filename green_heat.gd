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
				connect_as("")
		else:
			_disconnect_from_server()
		_enabled = value
	get():
		return _enabled && !Engine.is_editor_hint()
		
@export var minify_data: bool = false: # ask for a reduced packets data
	set(value):
		if (enabled): return
		minify_data = value

var _debug = false
var _processed_count: int = 0 # for debug reasons
var _last_ws_state: int = _ws.STATE_CLOSED # for debug reasons

var _ws := WebSocketPeer.new()
var _enabled: bool:
	set(value):
		_enabled = value
		set_process(value)

func _debug_print(text: String):
	if _debug:
		print("[GH_%s] %s" % [get_instance_id(), text])

func _ready():
	if !enabled: return
	_debug_print("connecting to GreenHeat on ready")
	connect_as("")

# connect to GreenHeat servers as the channel
func connect_as(_channel_name: String = ""):
	if _channel_name.length() > 0:
		channel_name = _channel_name

	if channel_name.length() == 0:
		printerr("can't connect to GreenHeat with an empty channel name")
		_enabled = false

	if _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		printerr("GreenHeat server is connected already")
		_enabled = false

	var url = _get_ws_url(true)
	_debug_print("connecting to %s.." % url)

	_enabled = true
	var code = _ws.connect_to_url(url)
	if code < 0:
		printerr("error while connecting to %s: %d" % [url, code])
		_enabled = false
	else:
		_debug_print("GreenHeat server returned code %d" % [code])
	
# connect to GreenHeat servers as the channel
func _disconnect_from_server():
	if _ws.get_ready_state() != _ws.STATE_CLOSED:
		var url = _get_ws_url(false)
		_debug_print("hard disconnect from %s" % url)
		_ws.close()

func _get_ws_url(force_generate: bool = true):
	var url = _ws.get_requested_url()
	if force_generate == true || url.length() <= 0:
		url = "wss://heat.prod.kr/%s" % channel_name
		if minify_data == true:
			url += "?minify"
	return url

func _process(_delta: float) -> void:
	_ws.poll()
	_processed_count += 1

	var state = _ws.get_ready_state()
	var is_state_changed = state != _last_ws_state
	if is_state_changed == true:
		_debug_print("%s | ws state changed from %s to %s" % [_processed_count, _ws_state_to_string(_last_ws_state), _ws_state_to_string(state)])

	if state == _ws.STATE_CLOSING || state == _ws.STATE_CLOSED:
		if is_state_changed == true:
			var code = _ws.get_close_code()
			# var reason = _ws.get_close_reason() # it's not provided so what the point
			printerr("%s connection to url %s with code %s" % [_ws_state_to_string(state), _get_ws_url(false), code])
	elif state == _ws.STATE_CONNECTING: pass
	elif state == _ws.STATE_OPEN:
		var packet_count: int # should update
		while true:
			packet_count = _ws.get_available_packet_count()
			if packet_count <= 0:
				break
			
			var raw = _ws.get_packet().get_string_from_utf8()
			# _debug_print("%s_%s | %s" % [_processed_count, packet_count, raw]) # spammy

			var packet = JSON.parse_string(raw)
			if packet == null:
				_debug_print("non-json packet!! %s" % raw) # might be spammy

			var input = GreenHeatInput.new()
			input._packet = packet
			input.is_minified = minify_data
			input_received.emit(input)
	else:
		printerr("unhandled websocket state: %s" % state)
		_enabled = false

	_last_ws_state = state
		
func _ws_state_to_string(state: int):
	match state:
		_ws.STATE_CLOSING: return "CLOSING"
		_ws.STATE_CLOSED: return "CLOSED"
		_ws.STATE_CONNECTING: return "CONNECTING"
		_ws.STATE_OPEN: return "OPEN"
		_: return "UNKNOWN %s" % state