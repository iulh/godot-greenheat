extends Node
class_name GreenHeat

signal input_received(input: GreenHeatInput) ## an exposed signal for detecting any inputs

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

@export var channel_name : String = "": ## this is the channel name
	set(value):
		if (channel_name.length() != 0 && enabled): return
		channel_name = value

var _debug = false
var _enabled: bool
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
	return "wss://heat.prod.kr/%s" % channel_name

func _process(delta: float) -> void:
	if !enabled:
		return
	_ws.poll()
	while _ws.get_available_packet_count() > 0:
		var raw = _ws.get_packet().get_string_from_utf8()
		var packet = JSON.parse_string(raw)
		if packet == null: continue
		var input = GreenHeatInput.new()
		input._packet = packet
		input_received.emit(input)
