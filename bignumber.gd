## A custom number type that stores numbers with a mantissa and exponent, allowing
## much larger numbers than ~1e+308
class_name BigNumber

## The Mantissa of the number in the form of [code]m * 10 ^ e[/code]
var m: float :
	set(value):
		m = value
		self._normalize()

## The Exponent of the number in the form of [code]m * 10 ^ e[/code]
var e: int

func _init(value: float):
	self.m = value
	self.e = 0

	self._normalize()


func _normalize() -> void:
	if self.m == 0.0:
		self.e = 0
	elif self.m < 1.0 or self.m >= 10.0:
		var delta = int(log(self.m) / log(10))
		self.m /= 10 ** delta
		self.e += delta


func _to_string() -> String:
	return "%.2fe%d" % [self.m, self.e]
