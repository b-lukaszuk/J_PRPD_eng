# optional, needed only to benchmark two solutions
import BenchmarkTools as Bt

const Str = String

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# rotBy >= 0 - returns (alphabet, rotatedAlphabet)
# rotBy < 0 - returns (rotatedAlphabet, alphabet)
function getAlphabets(rotBy::Int, upper::Bool)::Tuple{Str, Str}
    alphabet::Str = upper ? join('A':'Z') : join('a':'z')
    rot::Int = abs(rotBy) % length(alphabet)
    rotAlphabet::Str = alphabet[(rot+1):end] * alphabet[1:rot]
    return rotBy < 0 ? (rotAlphabet, alphabet) : (alphabet, rotAlphabet)
end

function codeChar(c::Char, rotBy::Int)::Char
    outerDisc::Str, innerDisc::Str = getAlphabets(rotBy, isuppercase(c))
    ind::Union{Int, Nothing} = findfirst(c, outerDisc)
    return isnothing(ind) ? c : innerDisc[ind]
end

# rotBy > 0 - encrypting, rotBy < 0 - decrypting, rotBy = 0 - same msg
function codeMsg(msg::Str, rotBy::Int)::Str
    coderFn(c::Char)::Char = codeChar(c, rotBy)
    return map(coderFn, msg)
end

# mini-tests
codeMsg("JULIA :)", 0)
codeMsg("JULIA :)", 0) == codeMsg("JULIA :)", 26)

codeMsg("AAA :)", 1)
codeMsg("AAA :)", 1) == codeMsg("AAA :)", 26+1) == codeMsg("AAA :)", 26*2+1)
codeMsg("aaa :)", 25)

codeMsg("JULIA :)", 2)
codeMsg("Julia :)", 2)
codeMsg("Julia :)", 2) |> txt -> codeMsg(txt, -2)

# decoding trarfvf.txt
codedTxt = open("./trarfvf.txt") do file # the file is roughly 31 KiB
    read(file, Str)
end

decodedTxt = codeMsg(codedTxt, -13)
first(decodedTxt, 54)
codeMsg("trarfvf", -13)

# improved version
function getEncryptionMap(rotBy::Int)::Dict{Char, Char}
    encryptionMap::Dict{Char, Char} = Dict()
    alphabet::Str = join('a':'z')
    rot::Int = abs(rotBy) % length(alphabet)
    rotAlphabet::Str = alphabet[(rot+1):end] * alphabet[1:rot]
    if rotBy < 0
        alphabet, rotAlphabet = rotAlphabet, alphabet
    end
    for i in eachindex(alphabet)
        encryptionMap[alphabet[i]] = rotAlphabet[i]
        encryptionMap[uppercase(alphabet[i])] = uppercase(rotAlphabet[i])
    end
    return encryptionMap
end

function code(c::Char, encryptionMap::Dict{Char, Char})::Char
    return get(encryptionMap, c, c)
end

function code(msg::Str, rotBy::Int)::Str
    encryptionMap::Dict{Char, Char} = getEncryptionMap(rotBy)
    coderFn(c::Char)::Char = code(c, encryptionMap)
    return map(coderFn, msg)
end

# benchmark (may take some time)
Bt.@benchmark(codeMsg($codedTxt, -13))
Bt.@benchmark(code($codedTxt, -13))
