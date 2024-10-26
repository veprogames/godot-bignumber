class_name ThousandSepNotation
extends BigNotation

func _init() -> void:
	super._init()

func get_number(n: BigNumber, precision: int = 0) -> String:
	var as_float: float = n.as_float()

	var format_string: String = "%%.%df" % precision
	var n_str: String = format_string % as_float
	
	var result: String = ""
	
	var end: int = n_str.find(".")
	if end == -1:
		end = len(n_str)
	for i: int in len(n_str):
		result += n_str[i]
		if (end - i) % 3 == 1 and i < end - 1:
			result += ","
	
	return result
