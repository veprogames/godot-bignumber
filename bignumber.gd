## A custom number type that stores numbers with a mantissa and exponent, allowing
## much larger numbers than ~1e+308.
##
## Methods like [method add], [method sub], [method mul], and [method div] can be chained,
## since they return new BigNumber instances.
##
## Those methods can operate with [BigNumber],
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
## 2. [code]BigNumber.new(1.4, 6) # instantiate a BigNumber with a mantissa and exponent;
## 1.4 * 10 ^ 6 in this case[/code]
##
## 3. [code]BigNumber.new(other_big_number) # instantiate a BigNumber from another.
## This can be used to clone an existing BigNumber[/code]
func _init(value: Variant, exponent: int = 0):
	if value is float or value is int:
		self.m = value
		self.e = exponent
	elif value is BigNumber:
		self.m = value.m
		self.e = value.e

	self._normalize()


func _normalize() -> void:
	var am := absf(self.m)
	if self.m == 0.0:
		self.e = 0
	elif am < 1.0 or am >= 10.0:
		var delta := int(floorf(log(am) / log(10)))
		self.m /= 10.0 ** delta
		self.e += delta


## Return a [BigNumber] instance from another [BigNumber], [String], [float], or [int]. This method
## is used internally in methods like [method mul] or [method Div], so these methods can
## take values of these types.
static func valueof(value: Variant) -> BigNumber:
	if value is String:
		return BigNumber.parse(value)
	elif value is float or value is int:
		return BigNumber.new(value)
	return BigNumber.new(value)


## Multiply [member self] with [param value], returning a new [BigNumber] instance
func mul(value: Variant) -> BigNumber:
	var b := BigNumber.valueof(value)
	b.m *= self.m
	b.e += self.e
	b._normalize()
	return b


## Divide [member self] with [param value], returning a new [BigNumber] instance
func div(value: Variant) -> BigNumber:
	var b := BigNumber.valueof(value)
	b.m /= self.m
	b.e -= self.e
	b._normalize()
	return b


## Add [param value] to [member self], returning a new [BigNumber]
func add(value: Variant) -> BigNumber:
	var b := BigNumber.valueof(value)
	var delta := b.e - self.e
	if delta >= 15:
		return b
	elif delta <= -15:
		return self
	b.m += self.m / 10.0 ** delta
	b._normalize()
	return b


## Substract [param value] from [member self], returning a new [BigNumber]
func sub(value: Variant) -> BigNumber:
	var b := BigNumber.valueof(value)
	return self.add(b.mul(-1))


## Get the logarithm to the base 10
func log10() -> float:
	if self.m == 0.0:
		return -INF
	return log(self.m) / log(10) + self.e

## Get the logarithm to the base [param base]
func log(base: float) -> float:
	return self.log10() / log(base)

## Get the natural logarithm to the base e (2.71828...)
func ln(base: float) -> float:
	# using 2.718281828 should be faster than exp(1)
	return self.log10() / log(2.718281828)


## Raise [member self] to the power of [param power], returning a new [BigNumber]
func pow(power: float) -> BigNumber:
	var log := self.log10()
	log *= power
	return BigNumber.new(10.0 ** fmod(log, 1.0), floorf(log))

## Return [member self] as a [float]
func as_float() -> float:
	return self.m * 10.0 ** self.e

## Return [member self] as an [int]
func as_int() -> int:
	return int(self.as_float())

## Round [member self] and return a new [BigNumber]. Behaves like [method @GlobalScope.round]
func round() -> BigNumber:
	# if number is very big, rounding is unnecessary
	if self.e >= 15:
		return self
	return BigNumber.new(roundf(self.as_float()))

## Round down [member self] and return a new [BigNumber]. Behaves like [method @GlobalScope.floor]
func floor() -> BigNumber:
	# if number is very big, rounding is unnecessary
	if self.e >= 15:
		return self
	# make it work for very small numbers, as at some point as_float just returns 0
	if self.e <= -15:
		return BigNumber.new(0) if self.m > 0 else BigNumber.new(-1)
	return BigNumber.new(floorf(self.as_float()))

## Round up [member self] and return a new [BigNumber]. Behaves like [method @GlobalScope.ceil]
func ceil() -> BigNumber:
	# if number is very big, rounding is unnecessary
	if self.e >= 15:
		return self
	# make it work for very small numbers, as at some point as_float just returns 0
	if self.e <= -15:
		return BigNumber.new(1) if self.m > 0 else BigNumber.new(0)
	return BigNumber.new(ceilf(self.as_float()))

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
