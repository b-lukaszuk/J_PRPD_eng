const Flt = Float64
const Str = String
const Vec = Vector

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# https://en.wikipedia.org/wiki/Bubble_sort
# sorts in ascending order
# uncomment the commented lines to sneak peek how the algorithm works
function bs(v::Vec{A})::Vec{A} where A<:Union{Flt, Int}
    result::Vec{A} = copy(v)
    swapped::Bool = true
    # i::Int = 0
    while swapped
        # i += 1
        # @show i
        swapped = false
        for i in eachindex(result)[2:end]
            if result[i-1] > result[i]
                result[i-1], result[i] = result[i], result[i-1]
                swapped = true
            end
            # @show result, swapped
        end
    end
    return result
end

[47, 15, 23, 99, 4] |> bs
[0.75, 0.25, 0.5] |> bs

# https://en.wikipedia.org/wiki/Quicksort
# Haskell-ic version (biased towards functional programming)
# sorts in ascending order
function qs(v::Vec{Int})::Vec{Int}
    if isempty(v)
        return []
    else
        head::Int, tail::Vec{Int}... = v
        smallerElts::Vec{Int} = filter((<)(head), tail)
        greaterEqElts::Vec{Int} = filter((>=)(head), tail)
        return [qs(smallerElts); head; qs(greaterEqElts)]
    end
end

[47, 15, 23, 99, 4] |> qs

# more imperative programming version
function qs(v::Vec{Int})::Vec{Int}
    if isempty(v)
        return []
    else
        firstElt::Int = v[1]
        otherElts::Vec{Int} = v[2:end]
        smallerElts::Vec{Int} = filter(elt -> elt < firstElt, otherElts)
        greaterEqElts::Vec{Int} = filter(elt -> elt >= firstElt, otherElts)
        return [qs(smallerElts); firstElt; qs(greaterEqElts)]
    end
end

[47, 15, 23, 99, 4] |> qs

# by - function(A) -> B; is applied to every elt of v before sorting
# lt - fn(B, B) -> Bool; compares pairs of elts after 'by' was applied
function qs(v::Vec{A}, by::Function=identity, lt::Function=<)::Vec{A} where A
    if isempty(v)
        return []
    else
        firstElt::A = v[1]
        otherElts::Vec{A} = v[2:end]
        smallerElts::Vec{A} = filter(
            elt -> lt(by(elt), by(firstElt)),
            otherElts
        )
        greaterEqElts::Vec{A} = filter(
            elt -> !lt(by(elt), by(firstElt)),
            otherElts
        )
        return [qs(smallerElts, by, lt); firstElt; qs(greaterEqElts, by, lt)]
    end
end

[0.75, 0.25, 0.5] |> qs
['c', 'b', 'a', 'd'] |> qs

# from ../cheque/cheque.jl
# https://en.wikipedia.org/wiki/English_numerals
const UNITS_AND_TEENS = Dict(1 => "one",
                             2 => "two", 3 => "three", 4 => "four",
                             5 => "five", 6 => "six", 7 => "seven",
                             8 => "eight", 9 => "nine", 10 => "ten",
                             11 => "eleven", 12 => "twelve",
                             13 => "thirteen", 14 => "fourteen",
                             15 => "fifteen", 16 => "sixteen",
                             17 => "seventeen", 18 => "eighteen",
                             19 => "nineteen")

const TENS = Dict(2 => "twenty", 3 => "thrity",
                  4 => "forty", 5 => "fifty", 6 => "sixty",
                  7 => "seventy", 8 => "eigthy", 9 => "ninety")

function getEngNumeral(n::Int)::Str
    @assert 0 < n < 1e6 "n must be in range (0-1e6)"
    major::Int, minor::Int = 0, 0
    if n < 20
        return UNITS_AND_TEENS[n]
    elseif n < 100
        major, minor = divrem(n, 10)
        return TENS[major] * (
            minor == 0 ? "" : "-" * UNITS_AND_TEENS[minor]
        )
    elseif n < 1000
        major, minor = divrem(n, 100)
        return getEngNumeral(major) * " hundred" * (
            minor == 0 ? "" : " and " * getEngNumeral(minor)
        )
    else # < 1e6 due to @assert above
        major, minor = divrem(n, 1_000)
        return getEngNumeral(major) * " thousand" * (
            minor == 0 ? "" :
            minor < 100 ? " and " * getEngNumeral(minor) :
            ", " * getEngNumeral(minor)
        )
    end
end

qs(collect(1:10), getEngNumeral)

qs([0.75, 0.25, 0.5]) == sort([0.75, 0.25, 0.5])
qs(['c', 'b', 'a', 'd']) == sort(['c', 'b', 'a', 'd'])
qs(collect(1:10), getEngNumeral) == sort(1:10, by=getEngNumeral)
