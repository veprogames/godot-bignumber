class_name ThousandSepNotation
extends BigNotation

func _init() -> void:
	super._init()

func get_number(n: BigNumber, precision: int = 0) -> String:
	var as_float: float = n.as_float()
	
	var fraction: String = ""
	if precision > 0:
		fraction = ("%f" % fmod(as_float, 1.0)).substr(1, precision + 1)

	var n_str: String = "%.0f" % floorf(as_float)
	
	var result: String = ""
	
	var c: int = 0
	for i: int in range(len(n_str) - 1, -1, -1):
		result = n_str[i] + result
		if c % 3 == 2 and i > 0:
			result = "," + result
		c += 1
	
	return "%s%s" % [result, fraction]
