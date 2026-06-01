const Str = String
const Vec = Vector

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

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

# or with log2 function
function getNumOfBits2codeDec(dec::Int)::Int
    @assert 0 <= dec <= 1024 "dec must be in range [0-1024]"
    twoPwr::Int = (dec < 2) ? 1 : ceil(Int, log2(dec))
    return (2^twoPwr > dec) ? twoPwr : twoPwr+1
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

all([dec2bin(i) == string(i, base=2) for i in 0:1024]) # Python like
# or simply, more Julia style
dec2bin.(0:1024) == string.(0:1024, base=2)

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

bin2dec.(string.(0:1024, base=2)) == 0:1024

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
        return getEqlLenBins(bin2, bin1) # OK, for addition and multiplication
    end
end

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

# binFn(Str, Str) -> Str, decFn(Int, Int) -> Int
function doesBinFnWork(dec1::Int, dec2::Int,
                       binFn::Function, decFn::Function)::Bool
    bin1::Str = binFn(dec2bin(dec1), dec2bin(dec2))
    bin2::Str = string(decFn(dec1, dec2), base=2)
    return bin1 == bin2
end

# running this test may take a few seconds (513x513 matrix)
tests = [doesBinFnWork(a, b, add, +) for a in 0:512, b in 0:512];
all(tests)

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

# 33x33 matrix so it should be relatively fast
tests = [doesBinFnWork(a, b, multiply, *) for a in 0:32, b in 0:32];
all(tests)
