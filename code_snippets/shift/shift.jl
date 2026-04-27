import CairoMakie as Cmk
import Makie.GeometryBasics.Point2f
import Makie.GeometryBasics.Polygon

const Flt = Float64
const Str = String
const Vec = Vector

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# code for 1st figure in the chapter
function getPtCoordinatesOnDisk(angleDeg::Flt,
                                radius::Flt=0.5)::Tuple{Flt, Flt}
    newX = radius * sin(deg2rad(angleDeg))
    newY = radius * cos(deg2rad(angleDeg))
    return (newX, newY)
end

function let2angleDeg(letter::Char)::Flt
    @assert letter in 'A':'Z' "letter must be in [A-Z] set"
    return (findfirst(letter, join('A':'Z')) - 1) * 360 / 26
end

function getXsAndYs(radius::Flt)::Tuple{Vec{Flt}, Vec{Flt}}
    @assert 0 <= radius <= 1 "radius must be in range [0, 1]"
    xs = Flt[]
    ys = Flt[]
    for letter in 'A':'Z'
        angDeg = let2angleDeg(letter)
        x, y = getPtCoordinatesOnDisk(angDeg, radius)
        push!(xs, x)
        push!(ys, y)
    end
    return (xs, ys)
end

function getRotatedAlphabet(alphabet::Str, rotBy::Int)::Str
    len::Int = length(alphabet)
    @assert 0 <= rotBy < len "rotBy must be in range [0-length(alphabet))"
    rotAlphabet::Str = alphabet[(rotBy+1):end] * alphabet[1:rotBy]
    return rotAlphabet
end

function drawCodingDiscs()::Cmk.Figure
    alphabet::Str = join('A':'Z')
    rotations::Vec{Flt} = LinRange(2pi, 0, 27)[1:end-1]
    rot::Int = 2
    shifts::Vec{Str} = "+" .* string.([rot:25..., 0:(rot-1)...])
    tick::Polygon = Polygon(
        Point2f[(-0.09, 0.5), (+0.09, 0.5), (0.18, 1.1), (-0.18, 1.1)],
        [Point2f[(-0.07, 0.53), (+0.07, 0.53), (0.14, 1.06), (-0.14, 1.06)]]
    )
    fig::Cmk.Figure = Cmk.Figure(size=(600, 600))
    ax::Cmk.Axis = Cmk.Axis(fig[1, 1])
    Cmk.pie!(ax, [100], color=:gold, strokewidth=0, radius=1)
    Cmk.text!(ax, getXsAndYs(0.85)...,
              text=split(alphabet, ""), align=(:center, :center),
              rotation=rotations)
    Cmk.pie!(ax, [100], color=:lightyellow, strokewidth=0, radius=0.75)
    Cmk.text!(ax, getXsAndYs(0.65)...,
              text=split(getRotatedAlphabet(alphabet, 2), ""),
              align=(:center, :center), rotation=rotations)
    Cmk.poly!(ax, tick, color=:crimson)
    Cmk.pie!(ax, [100], color=:lightgrey, strokewidth=0, radius=0.025)
    Cmk.text!(ax, getXsAndYs(0.58)..., text=shifts, color=:grey,
              align=(:center, :center), rotation=rotations, fontsize=12)
    Cmk.hidedecorations!(ax);
    Cmk.hidespines!(ax);
    return fig
end

# 1st figure in the chapter
drawCodingDiscs()

# Solution
codedTxt = open("./trarfvf.txt") do file # the file is roughly 31 KiB
    read(file, Str)
end

codedTxt = uppercase(codedTxt)

function isUppercaseLetter(c::Char)::Bool
    return c in 'A':'Z'
end

codedTxt = filter(isUppercaseLetter, codedTxt)

function getCounts(s::Str)::Dict{Char, Int}
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

function getFreqs(counts::Dict{Char, Int})::Dict{Char, Flt}
    total::Int = sum(values(counts))
    return Dict(k => v/total for (k, v) in counts)
end

function getFreqs(s::Str)::Dict{Char, Flt}
    return s |> getCounts |> getFreqs
end

codedLetFreqs = getFreqs(codedTxt)
[k => v for (k, v) in codedLetFreqs if v > 0.12]

# most frequent in English is 'E' ~0.127 or ~12.7%
# most frequent in codedTxt is 'R' ~0.134 or ~13.4%
'R' - 'E' # shift, ASCII: 82 - 69

function drawFreqComparison(
    freq2compare::Dict{Char, Flt},
    ylab::Str)::Cmk.Figure

    shift::Int = 13
    alphabet::Str = join('A':'Z')
    len::Int = length(alphabet)
    @assert 0 <= shift < len "shift must be in range [0-length(alphabet)"
    # https://en.wikipedia.org/wiki/Letter_frequency
    wikiFreqs::Vec{Flt} = [
        0.082, 0.015, 0.028, 0.043, 0.127, 0.022, 0.02, 0.061, 0.07,
        0.0015, 0.0077, 0.04, 0.024, 0.067, 0.075, 0.019, 0.00095,
        0.06, 0.063, 0.091, 0.028, 0.0098, 0.024, 0.0015, 0.02, 0.00074
    ]
    englishFreqs::Dict{Char, Flt} = Dict(
        c => wikiFreqs[i] for (i, c) in enumerate('A':'Z'))
    rotAlphabet::Str = getRotatedAlphabet(alphabet, shift)
    fig::Cmk.Figure = Cmk.Figure()
    ax1::Cmk.Axis = Cmk.Axis(fig[1, 1], xlabel="Frequency", xticks=0.0:0.05:1.0,
                             ylabel="plain English",
                             yticks=(1:len, split(alphabet[end:-1:1], "")),
                             ygridvisible=false)
    ax2::Cmk.Axis = Cmk.Axis(fig[1, 1], ylabel=ylab,
                             yticks=(1:len, split(rotAlphabet[end:-1:1], "")),
                             yaxisposition=:right, ylabelrotation=deg2rad(-90),
                             ygridvisible=false)
    Cmk.linkyaxes!(ax1, ax2)
    Cmk.linkxaxes!(ax1, ax2)
    Cmk.hidexdecorations!(ax2)
    Cmk.hidespines!(ax2)
    freqs1 = [englishFreqs[c] for c in alphabet]
    freqs2 = [freq2compare[c] for c in rotAlphabet]
    bp1 = Cmk.barplot!(ax1, len:-1:1, freqs1,
                color=(:blue, 0.3), direction=:x)
    bp11 = Cmk.barplot!(ax1, len:-1:1, freqs2,
                 color=(:red, 0.3), direction=:x)
    Cmk.Legend(fig[1, 2],
               [bp1, bp11], ["plain\nEnglish", replace(ylab, " " => "\n")],
               "Letter Frequencies")

    return fig
end

# 2nd figure in the chapter
drawFreqComparison(codedLetFreqs, "encrypted Message")
