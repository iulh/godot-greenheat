# Godot GreenHeat

> a godot wrapper of [GreenHeat](https://heat.prod.kr)

[GreenHeatGD](https://github.com/CrazyKitty357/greenheatgd) used as a base, but whatever i have a vision.

# Setup example
```gdscript
green_heat = GreenHeat.new()
add_child(green_heat)

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

# theoretically, the process can only be started from the script
green_heat.connect_as("channel_name")

# todo: a way to disconnect besides just removing the node
```

# GreenHeatInput
the `GreenHeatInput` matches websocket's packets, to be exact:
- "mobile" as bool
- "x" and "y" combined to "position" as Vector2
- "button" as String
- renamed "shift" to "is_shift_pressed" as bool
- renamed "ctrl" to "is_ctrl_pressed" as bool
- renamed "alt" to "is_alt_pressed" as bool
- "time" as float
- "latency" as float
- "type" as parsed InputType
  - CLICK (1) on type "click" 
  - HOVER (2) on type "hover"
  - DRAG (3) on type "drag"
  - RELEASE (4) on type "release"
  - UNKNOWN (0) if no match
- "id" as String
- renamed "isAnonymous" to "is_anonymous" as bool