class_name GreenHeatInput
extends RefCounted

var _packet: Variant
var is_minified: bool

enum InputType {
	UNKNOWN,
	CLICK,
	HOVER,
	DRAG,
	RELEASE
}

func _string_to_type_enum(type: String) -> InputType:
	match type:
		"click": return InputType.CLICK
		"hover": return InputType.HOVER
		"drag": return InputType.DRAG
		"release": return InputType.RELEASE
		_: return InputType.UNKNOWN

func minification(full: String, mini: String, default: Variant):
	var key = mini if is_minified else full
	if key.length() <= 0:
		return default

	var value = _packet[key]
	if (value == null):
		return value

	return default

var is_mobile: bool: # if the packet from a mobile device (can be minified)
	get():
		return minification("mobile", "", false)
var position: Vector2: # position from a stream screen
	get():
		return Vector2(_packet["x"], _packet["y"])
var button: String: # button name from the input (can be minified)
	get():
		return minification("button", "", "left")
var is_shift_pressed: bool: # if "shift" was pressed while the packet was sent (can be minified)
	get():
		return _packet["shift"]
var is_ctrl_pressed: bool: # if "ctrl" was pressed while the packet was sent (can be minified)
	get():
		return _packet["ctrl"]
var is_alt_pressed: bool: # if "alt" was pressed while the packet was sent (can be minified)
	get():
		return _packet["alt"]
var time: float: # time when the packet reached GreenHeat server (in milliseconds???) (can be minified)
	get():
		return _packet["time"]
var latency: float: # latency based on streamer and chatters internet in milliseconds
	get():
		return minification("latency_ms", "latency", 0)
var type: InputType: # type of the input
	get():
		return _string_to_type_enum(_packet["type"])
var id: String: # id from twitch account or anon
	get():
		return _packet["id"]
var is_anonymous: bool: # if the packet from not logged-in device (can be minified)
	get():
		return minification("is_anonymous", "", false)		

func  to_string():
	return "<GHI:%s_%s>" % [type, id]
