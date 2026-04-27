import Base.Iterators.takewhile as takewhile
import BenchmarkTools as Bt # external library

const Str = String
const Vec = Vector

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# codon - triplet of nucleotide bases, aa - amino acid
codon2aa = Dict(
    "UUU"=> "Phe", "UUC"=> "Phe", "UUA" => "Leu",
    "UUG" => "Leu", "CUU" => "Leu", "CUC" => "Leu",
    "CUA" => "Leu", "CUG" => "Leu", "AUU" => "Ile",
    "AUC" => "Ile", "AUA" => "Ile", "AUG" => "Met",
    "GUU" => "Val", "GUC" => "Val", "GUA" => "Val",
    "GUG" => "Val", "UCU" => "Ser", "UCC" => "Ser",
    "UCA" => "Ser", "UCG" => "Ser", "CCU" => "Pro",
    "CCC" => "Pro", "CCA" => "Pro", "CCG" => "Pro",
    "ACU" => "Thr", "ACC" => "Thr", "ACA" => "Thr",
    "ACG" => "Thr", "GCU" => "Ala", "GCC" => "Ala",
    "GCA" => "Ala", "GCG" => "Ala", "UAU" => "Tyr",
    "UAC" => "Tyr", "UAA" => "Stop", "UAG" => "Stop",
    "CAU" => "His", "CAC" => "His", "CAA" => "Gln",
    "CAG" => "Gln", "AAU" => "Asn", "AAC" => "Asn",
    "AAA" => "Lys", "AAG" => "Lys", "GAU" => "Asp",
    "GAC" => "Asp", "GAA" => "Glu", "GAG" => "Glu",
    "UGU" => "Cys", "UGC" => "Cys", "UGA" => "Stop",
    "UGG" => "Trp", "CGU" => "Arg", "CGC" => "Arg",
    "CGA" => "Arg", "CGG" => "Arg", "AGU" => "Ser",
    "AGC" => "Ser", "AGA" => "Arg", "AGG" => "Arg",
    "GGU" => "Gly", "GGC" => "Gly", "GGA" => "Gly",
    "GGG" => "Gly"
)

# aa - amino acid,
# iupac - International Union of Pure and Applied Chemistry
aa2iupac = Dict(
    "Ala" => "A", "Arg" => "R", "Asn" => "N",
    "Asp" => "D", "Cys" => "C", "Gln" => "Q",
    "Glu" => "E", "Gly" => "G", "His" => "H",
    "Ile" => "I", "Leu" => "L", "Lys" => "K",
    "Met" => "M", "Phe" => "F", "Pro" => "P",
    "Ser" => "S", "Thr" => "T", "Trp" => "W",
    "Tyr" => "Y", "Val" => "V", "Stop" => "Stop"
)

# AA - amino acids
expectedAAseq = "MALWMRLLPLLALLALWGPDPAAAFVNQHLCGSHLVEAL" *
    "YLVCGERGFFYTPKTRREAEDLQVGQVELGGGPGA" *
    "GSLQPLALEGSLQKRGIVEQCCTSICSLYQLENYCN"

filePath = "./mrna_seq.txt"
filesize(filePath)

mRna = open(filePath) do file
    read(file, Str)
end
mRna[1:75]

# uppercasing the letters
mRna = uppercase(mRna)
mRna[1:5]

# translates codon/triplet to amino acid IUPAC
function getAA(codon::Str)::Str
    aaAbbrev::Str = get(codon2aa, codon, "???")
    aaIUPAC::Str = get(aa2iupac, aaAbbrev, "?")
    return aaIUPAC
end

function translate(mRnaSeq::Str)::Str
    len::Int = length(mRnaSeq)
    @assert len % 3 == 0 "the number of bases must be a multiple of 3"
    aas::Vec{Str} = fill("", Int(len/3))
    aaInd::Int = 0
    codon::Str, aa::Str = "", ""
    for i in 1:3:len
        aaInd += 1
        codon = mRnaSeq[i:(i+2)]
        aa = getAA(codon)
        # if block could be replaced with: aa == "Stop" && break
        if aa == "Stop"
            break
        end
        aas[aaInd] = aa
    end
    return join(aas)
end

protein = translate(mRna)
expectedAAseq == protein

# functional programming solution
function translate2(mRnaSeq::Str)::Str
    len::Int = length(mRnaSeq)
    @assert len % 3 == 0 "the number of bases is not a multiple of 3"
    ranges::Vec{UnitRange{Int}} = map(:, 1:3:len, 3:3:len)
    codons::Vec{Str} = map(r -> mRnaSeq[r], ranges)
    aas::Vec{Str} = map(getAA, codons)
    return takewhile(aa -> aa != "Stop", aas) |> join
end

protein2 = translate2(mRna)
expectedAAseq == protein2

# benchmark (may take some time)
Bt.@benchmark translate($mRna)
Bt.@benchmark translate2($mRna)

# benchmark (may take some time)
Bt.@benchmark translate($(mRna^20))
Bt.@benchmark translate2($(mRna^20))
