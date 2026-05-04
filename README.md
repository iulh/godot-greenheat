# Godot GreenHeat

> a godot wrapper of [GreenHeat](https://heat.prod.kr)

[GreenHeatGD](https://github.com/CrazyKitty357/greenheatgd) used as a base, but whatever i have a vision.

# Setup example
```gdscript
var green_heat: GreenHeat

green_heat.input_received.connect(func(input: GreenHeatInput):
    match input.type:
        GreenHeatInput.InputType.CLICK:
            print("%s just clicked the mouse" % input.id)
        GreenHeatInput.InputType.RELEASE:
            print("%s just released the mouse" % input.id)
        GreenHeatInput.InputType.DRAG:
            # print("%s drags the screen" % input.id)
            pass # spammy
        GreenHeatInput.InputType.HOVER:
            # print("%s hovers the screen" % input.id)
            pass # spammy
)


# verbose mode if you even need it
green_heat._debug = true

# minified data reduces bandwidth by cutting unnecessary data
green_heat.minify_data = true


# connect from a script
green_heat.connect_as("channel_name")

# or connect this way
green_heat.channel_name = "channel_name"
green_heat.connect_as("")

# enabling from the editor will initiate connection too
green_heat.channel_name = "channel_name"
green_heat.enabled = true


# disabling the node disconnects from the server
green_heat.enabled = false

# freeing also works
green_heat,free()
```

# GreenHeatInput
the `GreenHeatInput` matches websocket's received packets. for a record:
- variable "mobile" as `bool`
- values "x" and "y" combined to variable "position" as type `Vector2`
- variable "button" as type `String`
- renamed value "shift" to variable "is_shift_pressed" as type `bool`
- renamed value "ctrl" to variable "is_ctrl_pressed" as type `bool`
- renamed value "alt" to variable "is_alt_pressed" as type `bool`
- variable "time" as type `float`
- variable "latency" as type `float`
- variable "type" as parsed enum `InputType`
  - enum `CLICK` (1) on value "click" 
  - enum `HOVER` (2) on value "hover"
  - enum `DRAG` (3) on value "drag"
  - enum `RELEASE` (4) on value "release"
  - enum `UNKNOWN` (0) if no match
- variable "id" as type `String`
- variable "is_anonymous" as type `bool`