extends Node
class_name GreenHeat

signal input_received(input: GreenHeatInput) # an exposed signal for detecting any inputs

@export var detecting : bool = true ## this enables / disables the clickmap on the fly
@export var debug = true ## for debug purposes

var channel_name : String = "" ## this is the channel name
var _ws := WebSocketPeer.new()

func _debug_print(text: String):
	if debug: print(text)

# connect to GreenHeat servers as the channel
func connect_as(_channel_name: String) -> void:
	if not Engine.is_editor_hint():
		channel_name = _channel_name
		var url = "wss://heat.prod.kr/%s" % channel_name
		_debug_print("connecting to %s.." % url)
		_ws.connect_to_url(url)

func _process(delta: float) -> void:
	if not detecting or Engine.is_editor_hint(): return
	_ws.poll()
	while _ws.get_available_packet_count() > 0:
		var raw = _ws.get_packet().get_string_from_utf8()
		var packet = JSON.parse_string(raw)
		if packet == null: continue
		var input = GreenHeatInput.new()
		input._packet = packet
		input_received.emit(input)