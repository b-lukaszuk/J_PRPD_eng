import CairoMakie as Cmk

const Flt = Float64
const Str = String
const Vec = Vector

# WARNING
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

function isAsciiLetter(c::Char)::Bool
    return isascii(c) && isletter(c)
end

function codeMsg(msg::Str, passphrase::Str, decode::Bool=false)::Str
    @assert isascii(msg) "msg must contain only ASCII characters"
    @assert(isascii(passphrase),
            "passphrase must contain only ASCII characters")
    pass::Str = filter(isAsciiLetter, lowercase(passphrase))
    pwr::Int = ceil(length(msg) / length(pass))
    pass = pass ^ pwr
    shifts::Vec{Int} = [c - 'a' for c in pass]
    if decode
        shifts .*= -1
    end
    result::Vec{Char} = Vec{Char}(undef, length(msg))
    shiftsInd::Int = 1
    for (ind, char) in enumerate(msg)
        result[ind] = codeChar(char, shifts[shiftsInd])
        if isAsciiLetter(char)
            shiftsInd += 1
        end
    end
    return result |> join
end

m = "attacking tonight"
p = "oculorhinolaryngology"

res1 = codeMsg(m, p)
res2 = "ovnlqbpvt hznzeuz" # expected result
res1 == res2

codeMsg(res2, p, true)

# frequencies of genesis coded with vigenere cipher
plainTxt = open("./genesis.txt") do file
    read(file, Str)
end
passphrase = "Julia rocks, believe in its magic."
codedTxt = codeMsg(plainTxt, passphrase)

plainTxt = filter(isAsciiLetter, uppercase(plainTxt))
codedTxt = filter(isAsciiLetter, uppercase(codedTxt))

function getCounts(s::Str)::Dict{Char,Int}
    counts::Dict{Char, Int} = Dict()
    for char in s
        if haskey(counts, char)
            counts[char] = counts[char] + 1
        else
            counts[char] = 1
        end
    end
    return counts
end

function getFreqs(counts::Dict{Char, Int})::Dict{Char,Flt}
    total::Int = sum(values(counts))
    return Dict(k => v/total for (k, v) in counts)
end

function getFreqs(s::Str)::Dict{Char,Flt}
    return s |> getCounts |> getFreqs
end

function drawFreqComparison(txt1::Str, title1::Str,
                            txt2::Str, title2::Str)::Cmk.Figure
    letFreqs1::Dict{Char, Flt} = getFreqs(txt1)
    letFreqs2::Dict{Char, Flt} = getFreqs(txt2)
    alphabet::Str = join('A':'Z')
    reversedAlphabet::Str = alphabet[end:-1:1]
    len::Int = length(alphabet)
    freqs1::Vec{Flt} = [get(letFreqs1, c, 0) for c in alphabet]
    freqs2::Vec{Flt} = [get(letFreqs2, c, 0) for c in alphabet]
    fig::Cmk.Figure = Cmk.Figure(size=(600, 1200))
    ax1::Cmk.Axis = Cmk.Axis(fig[1, 1], title=title1,
                             xlabel="Frequency in text", ylabel="Letter",
                             yticks=(1:len, split(reversedAlphabet, "")),
                             ygridvisible=false)
    ax2::Cmk.Axis = Cmk.Axis(fig[2, 1], title=title2,
                             xlabel="Frequency in text", ylabel="Letter",
                             yticks=(1:len, split(reversedAlphabet, "")),
                             ygridvisible=false)
    Cmk.linkyaxes!(ax1, ax2)
    Cmk.linkxaxes!(ax1, ax2)
    Cmk.barplot!(ax1, len:-1:1, freqs1, color=:deepskyblue3, direction=:x)
    Cmk.barplot!(ax2, len:-1:1, freqs2, color=:deepskyblue3, direction=:x)
    return fig
end

drawFreqComparison(plainTxt, "genesis.txt in plain text",
                   codedTxt, "genesis.txt coded with a Vigenere cipher")
