# Binary {#sec:binary}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/binary)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:binary_problem}

Numbers, or information in general, can be written down in different forms. The
most basic one, and the only one that is actually understood by a computer, is a
binary. Usually, it is depicted by a sequence of 1s and 0s, but it could be
anything really. Anything, that can take two separate states. The once common
[CDs](https://en.wikipedia.org/wiki/Compact_disc) or
[DVDs](https://en.wikipedia.org/wiki/DVD) are a sequence of laser burns (tiny
pits) in a spiral track (burn - 1, no burn - 0). The [hard disk
drives](https://en.wikipedia.org/wiki/Hard_disk_drive) store data as magnetized
spots, whereas [SSD drives](https://en.wikipedia.org/wiki/Solid-state_drive)
cash it as electrons trapped in tiny transistors. The data on a hard drive can
be interpreted as decimal digits, which in turn can be interpreted as characters
from an alphabet (like [ASCII](https://en.wikipedia.org/wiki/ASCII)). Moreover,
the data can be read into memory (RAM) and send to a processor for calculations.

This time you task is to read about the [binary
numbers](https://en.wikipedia.org/wiki/Binary_number). Alternatively, you may
watch some online videos (e.g. from [Khan
Academy](https://www.youtube.com/watch?v=ku4KOFQ-bB4&list=PLS---sZ5WJJvsjaAQZKwTwxl910xUdO98))
on the topic. Next, to get a better grasp of the subject write:

- a function that transforms a binary number to its decimal counterpart
- a function that transforms a decimal number to its binary counterpart
- a function that adds two binary numbers
- a function that multiplies two binary numbers

For simplicity, assume that the functions will operate only on natural numbers
in the range of let's say 0 to 1024 (in decimal). You may check your functions
against the built-in `string` and `parse` functions. For instance,
`string(3, base=2)` converts the decimal (3) to its binary representation and
`parse(Int, "11", base=2)` performs the opposite action.

## Solution {#sec:binary_solution}

Let's start with our `dec2bin` converter, we'll base it on the [Khan Academy
videos](https://www.youtube.com/watch?v=ku4KOFQ-bB4&list=PLS---sZ5WJJvsjaAQZKwTwxl910xUdO98)
and similarities with the decimal number system.

[The decimal system](https://en.wikipedia.org/wiki/Decimal) operates on
base 10. A number, let's say: one hundred and twenty-three (123), can be written
with digits ([0-9]) placed in three slots. We know this because three slots
allow us to write $10^3 = 1000$ numbers ([0-999]), whereas two slots are good
only for $10^2 = 100$ numbers ([0-99], compare also with the [exercise
1](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_intro_exercises.html#sec:statistics_intro_exercise1)
and [its
solution](https://b-lukaszuk.github.io/RJ_BS_eng/statistics_intro_exercises_solutions.html#sec:statistics_intro_exercise1_solution)).
The number 123 is actually a sum of one hundred, two tens, and three units
($1*100 + 2*10 + 3*1$ = `sum([1*100, 2*10, 3*1])` = `jl sum([1*100, 2*10, 3*1])`).
Equivalently, this can be written with the consecutive powers of ten
($10^x$ = `10^x` in Julia's code), i.e. $1*10^2 + 2*10^1 + 3*10^0$ =
`sum([1*10^2, 2*10^1, 3*10^0])` = `jl sum([1*10^2, 2*10^1, 3*10^0])`. Pause for
a moment and make sure you got that.

Similar reasoning applies to binary numbers, but here we operate on the powers
of two. A decimal number, let's say: fourteen (14), can be written with digits
([0-1]) placed in four slots. This is because $2^4$ allows us to write down 16
numbers (in binary: [0000-1111], in decimal: [0-15]), whereas $2^3$ suffices
only for 8 numbers (in binary: [000-111], in decimal: [0-7]). Each slot (from
right to left) represents subsequent powers of two, i.e. ones ($2^0 = 1$), twos
($2^1 = 2$), fours ($2^2 = 4$), and eights ($2^3 = 8$). Once again we sum the
digits to get our encoded number `1110` =
$1*2^3 + 1*2^2 + 1*2^1 + 1*2^0$ = $1*8 + 1*4 + 1*2 + 1*0$ =
`sum([1*8, 1*4, 1*2, 1*0])` = `jl sum([1*8, 1*4, 1*2, 1*0])`. Time to put that
knowledge to good use by writing our `dec2bin`.

```jl
s = """
function getNumOfBits2codeDec(dec::Int)::Int
    @assert 0 <= dec <= 1024 "dec must be in range [0-1024]"
    dec = (dec == 0) ? 1 : dec
    for i in 1:dec
        if 2^i > dec
            return i
        end
    end
    return 0 # should never happen
end

function dec2bin(dec::Int)::Str
    @assert 0 <= dec <= 1024 "dec must be in range [0-1024]"
    nBits::Int = getNumOfBits2codeDec(dec)
    result::Vec{Char} = fill('0', nBits)
    bitDec::Int = 2^(nBits-1) # -1, because powers of 2 start at 0 not 1
    for i in eachindex(result)
        if bitDec <= dec
            result[i] = '1'
            dec -= bitDec
        end
        bitDec = div(bitDec, 2)
    end
    return join(result)
end
"""
sc(s)
```

We begin by declaring `getNumOfBits2codeDec`, a function that will help us to
find how many bits (slots) we need in order to code a given decimal as a binary
number. It does so by using a 'brute force' approach (`for i in 1:dec`) with an
early stop mechanism (`if 2^i > dec`). As an alternative we may consider to
use the built-in `log2` function, but the approach presented here just seemed so
natural and in line with the previous explanations that I just couldn't resist.

As for the `dec2bin` function we start by declaring a few helper variables:
`nBits` - number of bits/slots we need to fill in order to code our number,
`result` - a vector that will hold our final binary representation, and
`bitDec` - a variable that will store the consecutive powers of 2 (expressed in
decimal) coded by a given bit. Next, we traverse the bits/slots of our `result`
from left to right. When the current power of two is smaller or equal to the
decimal we got to encode (`if bitDec <= dec`) then we set that particular bit to
1 (`result[i] = '1'`) and reduce the decimal we still need to encode by that
value (`dec -= bitDec`). Moreover, we update (reduce) our consecutive powers of
two (`bitDec`) by using the 2 divisor (`div(bitDec, 2)`). `div` performs an
integer division (that drops the decimal part of the quotient). We use it
because in the array of the powers of two: $2^4 = 16, 2^3 = 8, 2^2 = 4, 2^1 = 2,
2^0 = 1$ each number gets two times smaller. The `div(bitDec, 2)` protects us
from the case when the integer division by 2 with standard `bitDec/2` would not
be possible (in the last turnover of the loop `bitDec` will be equal to `1`).

Let's see how it works with a couple of numbers.

```jl
s = """
lpad.(dec2bin.(0:8), 4, '0')
"""
replace(sco(s), "\", " => "\",\n", "[" => "[\n", "]" => "\n]")
```

Time for a benchmark against the built-in `string` function.

```jl
s = """
all([dec2bin(i) == string(i, base=2) for i in 0:1024]) # Python like
# or simply, more Julia style
dec2bin.(0:1024) == string.(0:1024, base=2)
"""
sco(s)
```

It appears we did just fine as the function produces the same results as
`string`.

Once we got it reversing the process should be a breeze.

```jl
s = """
function isBin(bin::Char)::Bool
    return bin in ['0', '1']
end

function isBin(bin::Str)::Bool
    return isBin.(collect(bin)) |> all
end

function bin2dec(bin::Str)::Int
    @assert isBin(bin) "bin is not a binary number"
    pwr::Int = length(bin) - 1 # -1, because powers of 2 start at 0 not 1
    result::Int = 0
    for b in bin
        result += (b == '1') ? 2^pwr : 0
        pwr -= 1
    end
    return result
end
"""
sc(s)
```

Once again, we we start our main function (`bin2dec`) with the definition of a
few helper variables: `pwr` - which holds a power of the current bit which is in
the range from `length(bin)-1` to `0` (from the leftmost to the rightmost bit),
and `result` which is just a sum of all bits expressed in decimal system. We
build the sum (`result +=`) bit by bit (`for b in bin`), but only for the bits
equal `'1'` (`(b == `1`) ? 2^pwr`) while reducing the power for the next bit as
we shift right (`pwr -= 1`). Finally, all that's left to do is to `return` the
`result`.

Let's see how we did.

```jl
s = """
lpad.(dec2bin.(0:8), 4, '0') .|> bin2dec
"""
sco(s)
```

It looks good, and now for a more comprehensive benchmark.

```jl
s = """
bin2dec.(string.(0:1024, base=2)) == 0:1024
"""
sco(s)
```

Again, it seems that we can't complain.

OK, time to add two binaries.

> **_Note:_** Before you move further, I suggest you take a pen and paper and do
> the addition and multiplication for some decimals and binaries to get a better
> grasp of the process that we will translate into Julia's code.

```jl
s = """
# returns (carried bit, running bit)
function add(bin1::Char, bin2::Char)::Tuple{Char, Char}
    @assert isBin(bin1) && isBin(bin2) "both inputs must be binary bits"
    if bin1 == '1' && bin2 == '1'
        return ('1', '0')
    elseif bin1 == '0' && bin2 == '0'
        return ('0', '0')
    else
        return ('0', '1')
    end
end

function getEqlLenBins(bin1::Str, bin2::Str)::Tuple{Str, Str}
    if length(bin1) >= length(bin2)
        return (bin1, lpad(bin2, length(bin1), '0'))
    else
        return getEqlLenBins(bin2, bin1)
    end
end
"""
sc(s)
```

In order to add two binary numbers we need to define how to add two binary
digits (`bin1::Char` and `bin2::Char`) first. Just like in the decimal system we
need to handle the overflow, e.g. when we add $26 + 8$, first we add 8 and 6 to
get 14. Four (the second digit of 14) becomes the running bit and 1 (the first
digit of 14) becomes a carried bit that we add to 2 (the first digit in 26) to
get our final score which is 34. By analogy, `add(bin1::Char, bin2::Char)`
returns a tuple (`Tuple{Int, Int}`) with the carried and running bit,
respectively.

Additionally, we defined `getEqlLenBins` that makes sure the two numbers (`bin1`
and `bin2`) are of equal length. This is because the upcoming `add(bin1::Str,
bin2::Str)` will rely on the above `add(bin1::Char, bin2::Char)`, that's why the
shorter number will be padded on the left with zeros (by `lpad`), which is a
neutral digit in addition (in decimal adding 26+8 is the same as adding
26+08). Two points of notice. First of all, make sure to use `>=` and not `>` in
the first `if` statement otherwise you will end up with an infinite recursion
(see @sec:recursion) and [stack
overflow](https://en.wikipedia.org/wiki/Stack_overflow) error in some cases
(test yourself and explain why it will happen for `getEqlLenBins("01",
"10")`). Secondly, the recursive call `getEqlLenBins(bin2, bin1)` effectively
swaps the numbers. This is a neat trick and makes no difference here (since
both addition and multiplication are
[commutative](https://en.wikipedia.org/wiki/Commutative_property)), but may
cause troubles otherwise. Anyway, time for `add(bin1::Str, bin2::Str)`.

```jl
s = """
function isZero(bin::Char)::Bool
    return bin == '0'
end

function isZero(bin::Str)::Bool
    return isZero.(collect(bin)) |> all
end

function add(bin1::Str, bin2::Str)::Str
    @assert isBin(bin1) && isBin(bin2) "both inputs must be binary numbers"
    bin1, bin2 = getEqlLenBins(bin1, bin2)
    carriedBit::Char = '0'
    runningBit::Char = '0'
    runningBits::Str = ""
    carriedBits::Str = "0"
    for (b1, b2) in zip(reverse(bin1), reverse(bin2))
        carriedBit, runningBit = add(b1, b2)
        runningBits = runningBit * runningBits
        carriedBits = carriedBit * carriedBits
    end
    if isZero(carriedBits)
        return isZero(runningBits) ? "0" : lstrip(isZero, runningBits)
    else
        return add(runningBits, carriedBits)
    end
end
"""
sc(s)
```

The key function is rather simple. First, we align the binaries to contain the
same number of bits/slots (`getEqlLenBins`) and declare (and initialize) a few
helper variables. Next, we move from right to left (`reverse` functions) by the
corresponding bits (`b1`, `b2`) of our binary numbers (`bin1` and `bin2`). We
add the bits together (`add(b1, b2)`) and prepend (`*` - glues `Char`s and
`String`s together) the obtained `runningBit` and `carriedBit` to `runningBits`
and `carriedBits`, respectively. Once we traveled every bit of `bin1` and
`bin2` (thanks to the `for` loop). We check if the `carriedBits` is equal to
zero (i.e. all bits are equal `0`). If so (`if isZero(carriedBits)`), then we
`return` our `runningBits` but without the excessive zeros (`lstrip(isZero,
runningBits)`) that might have been produced on the left site (since e.g. the
binary `010` is the same as `10`, just like the decimal `03` is the same as
`3`). However, if `runningBits` is equal zero (`isZero(runningBits) ?`) we
return `"0"` (because in this case `lstrip` would have returned an empty string,
i.e. `""`). Otherwise (`else`), we just add the carried bits to the running bits
(recursive `add(runningBits, carriedBits)` call). Notice, that in order for the
last statement to work `carriiedBits` need to be moved by 1 to the left with
respect to the `runningBits`. That is why, we initialized them with `"0"` and
not an empty string `""` in the first place (`carriedBits::Str = "0"`). If the
last two sentences are not clear, then go ahead take a pen and paper and add two
simple decimals with the carry (like in the primary school). Then you will see
that the carried bit is moved to the left.

Some test would be in order. And here is our testing powerhouse.

```jl
s = """
# binFn(Str, Str) -> Str, decFn(Int, Int) -> Int
function doesBinFnWork(dec1::Int, dec2::Int,
                       binFn::Function, decFn::Function)::Bool
    bin1::Str = binFn(dec2bin(dec1), dec2bin(dec2))
    bin2::Str = string(decFn(dec1, dec2), base=2)
    return bin1 == bin2
end
"""
sc(s)
```

`doesBinFnWork` accepts two decimals (`dec1`, `dec2`) and two functions
(`binFn`, `decFn`) as its arguments. Each of the functions should accept two
arguments (`binFn` binaries, and `decFn` decimals) and perform the same
operation on them. Notice, that inside of `doesBinFnWork` both `dec1` and `dec2`
are converted to binaries and send to `binFn`, whereas the result of
`decFn(dec1, dec2)` is converted to binary. In the end `bin1` and `bin2` are
compared to make sure that they are equal. All set, time for a test.

```jl
s = """
# running this test may take a few seconds (513x513 matrix)
tests = [doesBinFnWork(a, b, add, +) for a in 0:52, b in 0:52]
all(tests)
"""
replace(sco(s), "52" => "512")
```

Another day, another dollar. Time for the multiplication.

```jl
s = """
function multiply(bin1::Char, bin2::Char)::Char
    @assert isBin(bin1) && isBin(bin2) "both inputs must be binary bits"
    if bin1 == '1' && bin2 == '1'
        return '1'
    else
        return '0'
    end
end

function multiply(bin1::Str, bin2::Str)::Str
    @assert isBin(bin1) && isBin(bin2) "both inputs must be binary numbers"
    total::Str = "0"
    curProd::Str = "0"
    nZerosToPad::Int = 0
    for b in reverse(bin2)
        curProd = multiply.(b, collect(bin1)) |> join
        total = add(total, curProd * '0'^nZerosToPad)
        nZerosToPad += 1
    end
    return total
end
"""
sc(s)
```

Again, we begin by defining how to multiply two individual bits, and again it
resembles the multiplication in the decimal system. Once we got it, we move to
multiply the whole numbers (`multiply(bin1::Str, bin2::Str`)). Just like in the
decimal system we multiply all the bits (from right to left) from the second
number (`for b in reverse(bin2)`) by the bits in the first number
(`multiply.(b, collect(bin1)) |> join`). After each multiplication the product
(`curProd`) of `b` times `bin1` is summed
(`add(total, curProd * '0'^nZerosToPad`)) into a grand `total`. Just like in the
decimal system, `curProd` is shifted to left every time we do that, which is why
we defined and increased `nZerosToPad` variable. Let's test it out.

```jl
s = """
# 33x33 matrix so it should be relatively fast
tests = [doesBinFnWork(a, b, multiply, *) for a in 0:32, b in 0:32]
all(tests)
"""
sco(s)
```

I guess we did it again. Good for us.
