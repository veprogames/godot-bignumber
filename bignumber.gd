@tool
@icon("res://godot-bignumber/big.png")

## A custom number type that stores numbers with a mantissa and exponent, allowing
## much larger numbers than ~1e+308.
##
## Methods like [method add], [method sub], [method mul], and [method div] can be chained,
## since they return new BigNumber instances.
##
## These methods can operate with [BigNumber],
## [float], [int] and [String]
class_name BigNumber
extends Resource

const EPSILON: float = 0.001

## The Mantissa of the number in the form of [code]m * 10 ^ e[/code]
##as
## [b]Warning:[/b] Changing this value directly is discouraged and can lead to unexpected behaviour.
var m: float = 0.0

## The Exponent of the number in the form of [code]m * 10 ^ e[/code]
##
## [b]Warning:[/b] Changing this value directly is discouraged and can lead to unexpected behaviour.
var e: int = 0

## [code]BigNumber.new()[/code] can be called in 4 ways:
##
## 1. [code]BigNumber.new(1_400_000) # instantiate a BigNumber with a numeric value[/code]
##
## 2. [code]BigNumber.new(1.4, 6) # instantiate a BigNumber with a mantissa and exponent;
## 1.4 * 10 ^ 6 in this case[/code]
##
## 3. [code]BigNumber.new("1.4e6") # instantiate a BigNumber with a string.[/code]
##
## 4. [code]BigNumber.new(other_big_number) # instantiate a BigNumber from another.[/code]
## This can be used to clone an existing [BigNumber]
func _init(value: Variant = 0, exponent: int = 0) -> void:
	assert(value is String or value is float or value is int or value is BigNumber,
			"[BigNumber] Passed value must be one of: int, float, String, BigNumber")
	if value is float or value is int:
		self.m = value
		self.e = exponent
	elif value is String:
		@warning_ignore("unsafe_call_argument") # value is String
		var parsed: BigNumber = BigNumber.parse(value)
		self.m = parsed.m
		self.e = parsed.e
	elif value is BigNumber:
		self.m = value.m
		self.e = value.e

	self._normalize()


func _normalize() -> void:
	var am: float = absf(self.m)
	if self.m == 0.0:
		self.e = 0
	elif am < 1.0 or am >= 10.0:
		var delta: int = int(floorf(log(am) / log(10)))
		self.m /= 10.0 ** delta
		self.e += delta

func _get_property_list() -> Array[Dictionary]:
	return [
		{
			"name": "m",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR,
			"hint_string": "suffix: * 10ᵉ",
		},
		{
			"name": "e",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR,
		}
	]

## Return a [BigNumber] instance from another [BigNumber], [String], [float], or [int]. This method
## is used internally in methods like [method mul] or [method div], so these methods can
## take values of these types.
static func valueof(value: Variant) -> BigNumber:
	assert(value is String or value is float or value is int or value is BigNumber,
			"[BigNumber] Passed value must be one of: int, float, String, BigNumber")
	if value is String:
		@warning_ignore("unsafe_call_argument") # value is String
		return BigNumber.parse(value)
	elif value is float or value is int:
		return BigNumber.new(value)
	return BigNumber.new(value)


## Multiply [member self] with [param value], returning a new [BigNumber] instance
func mul(value: Variant) -> BigNumber:
	var b: BigNumber = BigNumber.valueof(value)
	b.m *= self.m
	b.e += self.e
	b._normalize()
	return b


## Divide [member self] with [param value], returning a new [BigNumber] instance
func div(value: Variant) -> BigNumber:
	var b: BigNumber = BigNumber.valueof(value)
	b.m = self.m / b.m
	b.e = self.e - b.e
	b._normalize()
	return b


## Add [param value] to [member self], returning a new [BigNumber]
func add(value: Variant) -> BigNumber:
	var b: BigNumber = BigNumber.valueof(value)
	var delta: int = b.e - self.e
	if delta >= 15:
		return b
	elif delta <= -15:
		return self
	b.m += self.m / 10.0 ** delta
	b._normalize()
	return b


## Substract [param value] from [member self], returning a new [BigNumber]
func sub(value: Variant) -> BigNumber:
	var b: BigNumber = BigNumber.valueof(value)
	return self.add(b.mul(-1))


## Get the logarithm to the base 10
func log10() -> float:
	if self.m == 0.0:
		return -INF
	return log(self.m) / log(10) + self.e

## Get the logarithm to the base [param base]
func Log(base: float) -> float:
	return self.log10() / log(base)

## Get the natural logarithm to the base e (2.71828...)
func ln() -> float:
	# using 2.718281828 should be faster than exp(1)
	return self.log10() / log(2.718281828)


## Raise [member self] to the power of [param power], returning a new [BigNumber]
func Pow(power: float) -> BigNumber:
	if self.m == 0:
		return BigNumber.new(0)
	var vlog: float = self.Abs().log10()
	vlog *= power
	var exponent: int = int(floorf(vlog))
	# should exactly odd exponents return a positive number? (-2 * -2 = 4)
	var mult: int = -1 if self.m < 0 else 1
	return BigNumber.new(10.0 ** fmod(vlog, 1.0) * mult, exponent)

## Return [member self] as a [float]
func as_float() -> float:
	return self.m * 10.0 ** self.e

## Return [member self] as an [int]
func as_int() -> int:
	var float_val: float = self.as_float()
	if float_val >= 0 and ceilf(float_val) - float_val < EPSILON:
		return ceili(float_val)
	elif float_val < 0 and floorf(float_val) - float_val < EPSILON:
		return floori(float_val)
	return int(self.as_float())

## Round [member self] and return a new [BigNumber]. Behaves like [method @GlobalScope.round]
func Round() -> BigNumber:
	# if number is very big, rounding is unnecessary
	if self.e >= 15:
		return self
	return BigNumber.new(roundf(self.as_float()))

## Round down [member self] and return a new [BigNumber]. Behaves like [method @GlobalScope.floor]
func Floor() -> BigNumber:
	# if number is very big, rounding is unnecessary
	if self.e >= 15:
		return self
	# make it work for very small numbers, as at some point as_float just returns 0
	if self.e <= -15:
		return BigNumber.new(0) if self.m > 0 else BigNumber.new(-1)
	return BigNumber.new(floorf(self.as_float()))

## Round up [member self] and return a new [BigNumber]. Behaves like [method @GlobalScope.ceil]
func Ceil() -> BigNumber:
	# if number is very big, rounding is unnecessary
	if self.e >= 15:
		return self
	# make it work for very small numbers, as at some point as_float just returns 0
	if self.e <= -15:
		return BigNumber.new(1) if self.m > 0 else BigNumber.new(0)
	return BigNumber.new(ceilf(self.as_float()))


## Return the absolute value of [member self]. Behaves like [method @GlobalScope.absf]
func Abs() -> BigNumber:
	return BigNumber.new(absf(self.m), self.e)


## Compare [member self] with [param value]. If [member self] is bigger than [param value],
## return [code]1[/code].
## If [member self] is smaller than [param value], return [code]-1[/code].
## Return [code]0[/code] if [member self] and [param value] are equal.
##
## [b]Note:[/b] Consider using [method gt], [method lt], [method eq], and so on, as they are simpler.
func compare(value: Variant) -> int:
	var b: BigNumber = BigNumber.valueof(value)
	if b.m == self.m and b.e == self.e:
		return 0
	if b.m < 0 and self.m >= 0:
		return 1
	if b.m >= 0 and self.m < 0:
		return -1

	var log_self: float = self.Abs().log10()
	var log_b: float = b.Abs().log10()

	if self.m < 0:
		return 1 if log_self < log_b else -1
	else:
		return 1 if log_self > log_b else -1

## Return whether [member self] is larger than [param value]
func gt(value: Variant) -> bool:
	return self.compare(value) == 1

## Return whether [member self] is larger than or equal to [param value]
func gte(value: Variant) -> bool:
	return self.compare(value) >= 0

## Return whether [member self] is smaller than [param value]
func lt(value: Variant) -> bool:
	return self.compare(value) == -1

## Return whether [member self] is smaller than or equal to [param value]
func lte(value: Variant) -> bool:
	return self.compare(value) <= 0

## Return whether [member self] is equal to [param value]
func eq(value: Variant) -> bool:
	return self.compare(value) == 0

## Return whether [member self] is not equal to [param value]
func neq(value: Variant) -> bool:
	return self.compare(value) != 0

## Return the largest value in ([member self], [param value2])
##
## [b]Note:[/b] This can be chained,
## for example: [code]var my_max = BigNumber.new(42).max(3).max(111).max("3.4e5")[/code]
## will assign [code]3.4e5[/code] to my_max
func Max(value: Variant) -> BigNumber:
	var b: BigNumber = BigNumber.valueof(value)
	return self if self.gt(b) else b

## Return the smallest value in ([member self], [param value2])
##
## [b]Note:[/b] This can be chained,
## for example: [code]var my_max = BigNumber.new(42).min(3).min(111).min("3.4e5")[/code]
## will assign [code]3[/code] to my_max
func Min(value: Variant) -> BigNumber:
	var b: BigNumber = BigNumber.valueof(value)
	return self if self.lt(b) else b

## Return [member self] constrained between [param min_value] and [param max_value]
## Behaves like [method @GlobalScope.clampf]
func Clamp(min_value: Variant, max_value: Variant) -> BigNumber:
	var vmin: BigNumber = BigNumber.valueof(min_value)
	var vmax: BigNumber = BigNumber.valueof(max_value)
	assert(vmax.gte(vmin), "[BigNumber] clamp: max_value must be greater or equal to min_value")
	if self.lt(vmin):
		return vmin
	if self.gt(vmax):
		return vmax
	return self


## Return a new [BigNumber] where the mantissa is rounded.
## For Example: [code]BigNumber.new(1234).rounded_mantissa(1)[/code] -> [code]1200[/code].
## This can be used to make numbers look rounder overall
func rounded_mantissa(places: int = 0) -> BigNumber:
	assert(places >= 0, "[BigNumber] Cannot pass negative precision to rounded_mantissa")
	return BigNumber.new(roundf(self.m * 10.0 ** places) / 10.0 ** places, self.e)


## Parse and return a new [BigNumber] instance from a given [String]. The String must be
## in the format of [code]xey[/code], where x is the mantissa and y is the exponent.
## This method is compatible with [method _to_string] outputs.
static func parse(from: String) -> BigNumber:
	var parts: Array[String] = from.split("e")
	if len(parts) == 2:
		return BigNumber.new(float(parts[0]), int(parts[1]))
	else:
		return BigNumber.new(float(parts[0]))


func _to_string() -> String:
	return "%.2fe%d" % [self.m, self.e]
