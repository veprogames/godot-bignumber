# GDScript BigNumber

Add Number support above 1e+308. The range is between 1.0e-MIN\_INT and 9.99e+MAX\_INT.

This is inspired by [break\_infinity.js](https://github.com/Patashu/break\_infinity.js). You will find working with this very similar to break\_infinity.js.

## Setup

Just clone this repo into your Godot project. This is not an Editor Plugin (as it does zero change to the Editor).

```bash
my_godot_project $ git submodule add https://github.com/veprogames/godot-bignumber.git
```

or

```bash
my_godot_project $ git clone https://github.com/veprogames/godot-bignumber.git
```

## Short Example

```py
func _ready() -> void:
    var num: BigNumber = BigNumber.new("1e450")
    print(num.pow(2.5))
```

The class and methods are documented in Godot Engines help feature.
