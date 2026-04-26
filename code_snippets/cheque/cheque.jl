const Str = String

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

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

function getEngNumeralUpto99(n::Int)::Str
    @assert 1 <= n <= 99 "n must be in range [1-99]"
    if n < 20
        return UNITS_AND_TEENS[n]
    end
    t::Int, u::Int = divrem(n, 10) # t - tens, u - units
    result::Str = TENS[t]
    if u != 0
        result *= "-" * UNITS_AND_TEENS[u]
    end
    return result
end

getEngNumeralUpto99.([5, 9, 11, 13, 20, 21, 25, 32, 40, 45,
                      58, 64, 66, 79, 83, 95, 99])

function getEngNumeralUpto999(n::Int)::Str
    @assert 1 <= n <= 999 "n must be in range [1-999]"
    if n < 100
        return getEngNumeralUpto99(n)
    end
    h::Int, t::Int = divrem(n, 100) # h - hundreds, t - tens
    result::Str = getEngNumeralUpto99(h) * " hundred"
    if t != 0
        result *= " and " * getEngNumeralUpto99(t)
    end
    return result
end

getEngNumeralUpto999.([5, 9, 11, 13, 20, 21, 25, 32, 40, 45,
                       58, 64, 66, 79, 83, 95, 99])
getEngNumeralUpto999.([101, 109, 110, 117, 120, 152, 200, 208, 394, 400, 999])

function getEngNumeralBelow1M(n::Int)::Str
    @assert 1 <= n <= 999_999 "n must be in range [1-999,999]"
    if n < 1000
        return getEngNumeralUpto999(n)
    end
    t::Int, h::Int = divrem(n, 1000) # t - thousands, h - hundreds
    result::Str = getEngNumeralUpto999(t) * " thousand"
    if h == 0
        return result
    elseif h < 100
        result *= " and "
    else
        result *= ", "
    end
    result *= getEngNumeralUpto999(h)
    return result
end

getEngNumeralBelow1M.([5, 9, 11, 13, 20, 21, 25, 32, 40, 45,
                       58, 64, 66, 79, 83, 95, 99])
getEngNumeralBelow1M.([101, 109, 110, 117, 120, 152, 200, 208, 394, 400, 999])
getEngNumeralBelow1M.([1_800, 4_547, 5_005, 10_800, 96_779,
                       108_090, 108_001, 189_014, 500_506,
                       889_308])

# shorter version
function getEngNumeral(n::Int)::Str # uses recursion
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

# comparison of two versions
xs = getEngNumeralBelow1M.([5, 9, 11, 13, 20, 21, 25, 32, 40, 45, 58, 64, 66, 79, 83, 95, 99])
ys = getEngNumeral.([5, 9, 11, 13, 20, 21, 25, 32, 40, 45, 58, 64, 66, 79, 83, 95, 99])
xs == ys

xs = getEngNumeralBelow1M.([101, 109, 110, 117, 120, 152, 200, 208, 394, 400, 999])
ys = getEngNumeral.([101, 109, 110, 117, 120, 152, 200, 208, 394, 400, 999])
xs == ys

xs = getEngNumeralBelow1M.([1_800, 4_547, 5_005, 10_800, 96_779,
                            108_090, 108_001, 189_014, 500_506, 889_308])
ys = getEngNumeral.([1_800, 4_547, 5_005, 10_800, 96_779,
                            108_090, 108_001, 189_014, 500_506, 889_308])
xs == ys
