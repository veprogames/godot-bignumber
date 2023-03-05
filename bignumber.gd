## A custom number type that stores numbers with a mantissa and exponent, allowing
## much larger numbers than ~1e+308.
##
## About the Methods:
## Methods that start with a capital letter (like [method Mul]) modify (mutate) the instance.
## Methods that start with a lowercase letter (like [method mul]) return a new instance.
## Using the uppercase methods reduce instantiations, saving a little bit of performance.
## The lowercase methods can be chained, since they return new BigNumber instances.
##
## Methods such as [method mul] and [method div] can operate with [BigNumber],
## [float], [int] and [String]
class_name BigNumber

## The Mantissa of the number in the form of [code]m * 10 ^ e[/code]
##
## [b]Warning:[/b] Changing this value directly is discouraged and can lead to unexpected behaviour.
var m: float

## The Exponent of the number in the form of [code]m * 10 ^ e[/code]
##
## [b]Warning:[/b] Changing this value directly is discouraged and can lead to unexpected behaviour.
var e: int

## [code]BigNumber.new()[/code] can be called in 3 ways:
##
## 1. [code]BigNumber.new(123) # instantiate a BigNumber with a numeric value[/code]
##
## 2. [code]BigNumber.new(1.4, 6) # instantiate a BigNumber with a mantissa and exponent; 1.4 * 10 ^ 6 in this case[/code]
##
## 3. [code]BigNumber.new(other_big_number) # instantiate a BigNumber from another. This can be used to clone an existing BigNumber[/code]
func _init(value: Variant, exponent: int = 0):
	if value is float or value is int:
		self.m = value
		self.e = exponent
	elif value is BigNumber:
		self.m = value.m
		self.e = value.e

	self._normalize()


func _normalize() -> void:
	var am = abs(self.m)
	if self.m == 0.0:
		self.e = 0
	elif am < 1.0 or am >= 10.0:
		var delta: int = floor(log(am) / log(10))
		self.m /= 10.0 ** delta
		self.e += delta


## Return a [BigNumber] instance from another [BigNumber], [String], [float], or [int]. This method
## is used internally in methods like [method mul] or [method Div], so these methods can also
## take values of these types.
static func valueof(value: Variant) -> BigNumber:
	if value is String:
		return BigNumber.parse(value)
	elif value is float or value is int:
		return BigNumber.new(value)
	return BigNumber.new(value)


## Multiply this number with another, directly modifying this number
func Mul(v: Variant) -> void:
	var b = BigNumber.valueof(v)
	self.m *= b.m
	self.e += b.e
	self._normalize()

## Multiply this number with another, returning a new [BigNumber] instance
func mul(v: Variant) -> BigNumber:
	var b = BigNumber.valueof(v)
	return BigNumber.new(self.m * b.m, self.e + b.e)


## Divide this number with another, directly modifying this number
func Div(v: Variant) -> void:
	var b := BigNumber.valueof(v)
	self.m /= b.m
	self.e -= b.e
	self._normalize()

## Divide this number with another, returning a new [BigNumber] instance
func div(v: Variant) -> BigNumber:
	var b := BigNumber.valueof(v)
	return BigNumber.new(self.m / b.m, self.e - b.e)


## Add [param value] to [member self], directly modifying this number
func Add(value: Variant) -> void:
	var b := BigNumber.valueof(value)
	var delta := b.e - self.e
	if delta >= 15:
		self.m = b.m
		self.e = b.e
		return
	elif delta <= -15:
		return
	self.m += b.m * 10.0 ** delta
	self._normalize()

## Add [param value] to [member self], returning a new [BigNumber] instance
func add(value: Variant) -> BigNumber:
	var b := BigNumber.valueof(value)
	b.Add(self)
	return b

## Parse and return a new [BigNumber] instance from a given [String]. The String must be
## in the format of [code]xey[/code], where x is the mantissa and y is the exponent.
## This method is compatible with [method _to_string] outputs.
static func parse(from: String) -> BigNumber:
	var parts := from.split("e")
	if len(parts) == 2:
		return BigNumber.new(float(parts[0]), int(parts[1]))
	else:
		return BigNumber.new(float(parts[0]))


func _to_string() -> String:
	return "%.2fe%d" % [self.m, self.e]
