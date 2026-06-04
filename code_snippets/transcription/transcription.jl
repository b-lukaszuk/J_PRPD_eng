const Str = String

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

filePath = "./dna_seq_template_strand.txt"
filesize(filePath)

dna = open(filePath) do file
    read(file, Str)
end
dna[1:75]

dna = replace(dna, " " => "", "\n" => "")
dna[1:75]

isascii(dna)

dnaExonsOnly = dna[2424:2610] * dna[3397:3542]
dnaExonsOnly[1:75]

# https://en.wikipedia.org/wiki/Complementarity_(molecular_biology)
# DNA template strand to mRNA
dna2mrna = Dict(
    'a' => 'u',
    'c' => 'g',
    'g' => 'c',
    't' => 'a'
)

function transcribe(nucleotideBase::Char,
    complementarityMap::Dict{Char, Char} = dna2mrna)::Char
    return get(complementarityMap, nucleotideBase, '?')
end

(
    transcribe('a'),
    transcribe('g'),
    transcribe('x')
)

function transcribe(dnaSeq::Str)::Str
    return map(transcribe, dnaSeq) # map uses transcribe from above
end

mRna = transcribe(dnaExonsOnly)
(
    dnaExonsOnly[1:10],
    mRna[1:10]
)

# or shortly
mRna = map(base -> get(dna2mrna, base, base), dnaExonsOnly)
(
    dnaExonsOnly[1:10],
    mRna[1:10]
)

# are there any unknown bases '?'' (artifacts)
findfirst(base -> base == '?', mRna) |> isnothing # if true, then it is OK
