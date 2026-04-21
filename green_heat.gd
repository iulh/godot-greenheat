extends Node
class_name GreenHeat

signal input_received(input: GreenHeatInput) ## an exposed signal for detecting any inputs

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
@export var channel_name : String = "": ## this is the channel name
	set(value):
		if (channel_name.length() > 0):
			printerr("todo: switch channels on variable change")
			return
		channel_name = value

var _debug = false
var _enabled: bool
var _ws := WebSocketPeer.new()

func _debug_print(text: String):
	if _debug:
		print(text)

func _ready():
	if !enabled: return
	_debug_print("connecting to GreenHeat on ready")
	connect_as("")

# connect to GreenHeat servers as the channel
func connect_as(_channel_name: String):
	if _channel_name.length() > 0:
		channel_name = _channel_name

	if _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_debug_print("GreenHeat is connected already")
		return

	var url = _get_ws_url()
	_debug_print("connecting to %s.." % url)
	_ws.connect_to_url(url)

	_enabled = true
	
# connect to GreenHeat servers as the channel
func _disconnect_from_server():
	if _ws.get_ready_state() != _ws.STATE_OPEN:
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
