# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

const Str = String

const CHARS = vcat('0':'9', 'a':'f')
const MIN_BASE = 2
const MAX_BASE = 16
const ADD_TBL = Dict{Int, Dict{Tuple{Char, Char}, Tuple{Char, Char}}}()
const MULT_TBL = Dict{Int, Dict{Tuple{Char, Char}, Tuple{Char, Char}}}()

# unfortunately, we need to fill our `const`s, but we'll do this only once
# and not touch (modify) ADD_TBL and MULT_TBL later on
for base in MIN_BASE:MAX_BASE
    ADD_TBL[base] = Dict()
    MULT_TBL[base] = Dict()
    for dec1 in 0:(base-1), dec2 in 0:(base-1) # 1 digit nums only
        n1 = string(dec1, base=base)[1]
        n2 = string(dec2, base=base)[1]
        sumOfNs = string(dec1 + dec2, base=base)
        prodOfNs = string(dec1 * dec2, base=base)
        s1, s2 = lpad(sumOfNs, 2, '0') # s1, s2 = carried, running slot
        p1, p2 = lpad(prodOfNs, 2, '0') # p1, p2 = carried, running slot
        ADD_TBL[base][(n1, n2)] = (s1, s2)
        MULT_TBL[base][(n1, n2)] = (p1, p2)
    end
end

# MULT_TBL alone is already sufficient to answer the question, i.e.
# 6*9 in different base num systems
# nevertheless, we'll modify the functions from ../binary/binary.jl
# just for extra practice

function isBaseN(num::Char, n::Int)::Bool
    @assert MIN_BASE <= n <= MAX_BASE "n not in [$MIN_BASE - $MAX_BASE]"
    return num in CHARS[1:n]
end

function isBaseN(num::Str, n::Int)::Bool
    return isBaseN.(collect(num), n) |> all
end

# returns (carried num, running num)
function add(num1::Char, num2::Char, base::Int)::Tuple{Char, Char}
    @assert isBaseN(num1, base) "$num1 is not a num of base $base"
    @assert isBaseN(num2, base) "$num2 is not a num of base $base"
    return ADD_TBL[base][(num1, num2)]
end

function getEqlLenNums(num1::Str, num2::Str)::Tuple{Str, Str}
    if length(num1) >= length(num2)
        return (num1, lpad(num2, length(num1), '0'))
    else
        return getEqlLenNums(num2, num1) # OK for addition and multiplication
    end
end

function isZero(num::Char)::Bool
    return num == '0'
end

function isZero(num::Str)::Bool
    return isZero.(collect(num)) |> all
end

function add(num1::Str, num2::Str, baseNums::Int)::Str
    num1, num2 = getEqlLenNums(num1, num2)
    carriedSlot::Char, runningSlot::Char = ('0', '0')
    runningSlots::Str = ""
    carriedSlots::Str = "0"
    for (n1, n2) in zip(reverse(num1), reverse(num2))
        carriedSlot, runningSlot = add(n1, n2, baseNums)
        runningSlots = runningSlot * runningSlots
        carriedSlots = carriedSlot * carriedSlots
    end
    if isZero(carriedSlots)
        return isZero(runningSlots) ? "0" : lstrip(isZero, runningSlots)
    else
        return add(runningSlots, carriedSlots, baseNums)
    end
end

# baseNFn(Str, Str, Int) -> Str, decFn(Int, Int) -> Int
function doesBaseNFnWork(dec1::Int, dec2::Int,
                       baseNFn::Function, baseN::Int,
                       decFn::Function)::Bool
    num1::Str = baseNFn(
        string(dec1, base=baseN), string(dec2, base=baseN), baseN)
    num2::Str = string(decFn(dec1, dec2), base=baseN)
    return num1 == num2
end

# running this test may take some time (512x512 matrix for each base num system)
for base in MIN_BASE:MAX_BASE
    tests = [doesBaseNFnWork(a, b, add, base, +) for a in 0:511, b in 0:511];
    println("base $base, tests passed? ", all(tests))
end

# returns (crried num, running num)
function multiply(num1::Char, num2::Char, base::Int)::Tuple{Char, Char}
    @assert isBaseN(num1, base) "$num1 is not a num of base $base"
    @assert isBaseN(num2, base) "$num2 is not a num of base $base"
    return MULT_TBL[base][(num1, num2)]
end

function multiply(num1::Char, num2::Str, base::Int)::Str
    carriedSlot::Char, runningSlot::Char = ('0', '0')
    carriedSlots::Str = "0"
    runningSlots::Str = ""
    for n in reverse(num2)
        carriedSlot, runningSlot = multiply(n, num1, base)
        runningSlots = runningSlot * runningSlots
        carriedSlots = carriedSlot * carriedSlots
    end
    return add(carriedSlots, runningSlots, base)
end

function multiply(num1::Str, num2::Str, base::Int)::Str
    total::Str = "0"
    curProd::Str = ""
    nZerosToPad::Int = 0
    for n in reverse(num1)
        curProd = multiply(n, num2, base) * ('0' ^ nZerosToPad)
        total = add(total, curProd, base)
        nZerosToPad += 1
    end
    return total
end

# running this test may take some time (128x128 matrix for each base num system)
for base in MIN_BASE:MAX_BASE
    tests = [doesBaseNFnWork(a, b, multiply, base, *) for a in 0:127, b in 0:127];
    println("base $base, tests passed? ", all(tests))
end

# check 6*9 (the question) in different base num systems
# alternatively you could just do the lookup in MULT_TBL
for base in 10:MAX_BASE # 9 can be coded with 1 digit in base 10:16
    println("base $base: 6 * 9 = $(multiply('6', '9', base) |> join)")
end

# for a change let's multiply 42 * 42 in different base systems
for base in 5:MAX_BASE # 4 can be coded with 1 digit in base 5:16
    println("base $base: 42 * 42 = $(multiply("42", "42", base) |> join)")
end
