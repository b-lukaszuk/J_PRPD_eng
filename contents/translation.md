# Translation {#sec:translation}

In this chapter I used the following external libraries.

```jl
s6 = """
import Base.Iterators.takewhile as takewhile # internal library
import BenchmarkTools as Bt # external library
"""
sc(s6)
```

Those were used only for the chapter's extras and are not strictly necessary to
solve the task.

Anyway, I recommend you try to solve the task on your own first. Once you finish
you may compare your solution with the one in this chapter (with explanations)
or with [the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/translation)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:translation_problem}

Let's start from where we left. Read the data from the file: `mrna_seq.txt` (to
be found in [the code snippets for this
chapter](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/translation)). It
contains the mRNA sequence we obtained previously (see
@sec:transcription_solution).

Your task is to translate the language of nucleic acids to the language of
proteins. To do that you will operate on triplets of nucleotide bases (also
called codons). You start with the `AUG` triplet (the sequence starts with it)
and replace it with a proper amino acid (proteins are build of amino acids like
`String`s are build of `Char`s), in this case it is methionine. Then you move to
another triplet (there are no 'commas' in the genetic code) and assign the
proper amino acid according to the [standard genetic
code](https://en.wikipedia.org/wiki/DNA_and_RNA_codon_tables#Translation_table_1). You
finish the protein synthesis once you encounter a stop codon (`UAA`, `UAG`,
`UGA`).

Since rewriting the Wikipedia's table from the link above is mundane and boring,
then I paste the genetic code below in Julia's dictionary format.

```jl
s = """
# codon - triplet of nucleotide bases, aa - amino acid
codon2aa = Dict(
	"UUU"=> "Phe", "UUC"=> "Phe", "UUA" => "Leu", "UUG" => "Leu",
	"CUU" => "Leu", "CUC" => "Leu", "CUA" => "Leu", "CUG" => "Leu",
	"AUU" => "Ile", "AUC" => "Ile", "AUA" => "Ile", "AUG" => "Met",
    "GUU" => "Val", "GUC" => "Val", "GUA" => "Val", "GUG" => "Val",
	"UCU" => "Ser", "UCC" => "Ser", "UCA" => "Ser", "UCG" => "Ser",
	"CCU" => "Pro", "CCC" => "Pro", "CCA" => "Pro", "CCG" => "Pro",
    "ACU" => "Thr", "ACC" => "Thr", "ACA" => "Thr", "ACG" => "Thr",
	"GCU" => "Ala", "GCC" => "Ala", "GCA" => "Ala", "GCG" => "Ala",
	"UAU" => "Tyr", "UAC" => "Tyr", "UAA" => "Stop", "UAG" => "Stop",
    "CAU" => "His", "CAC" => "His", "CAA" => "Gln", "CAG" => "Gln",
	"AAU" => "Asn", "AAC" => "Asn", "AAA" => "Lys", "AAG" => "Lys",
	"GAU" => "Asp", "GAC" => "Asp", "GAA" => "Glu", "GAG" => "Glu",
    "UGU" => "Cys", "UGC" => "Cys", "UGA" => "Stop", "UGG" => "Trp",
	"CGU" => "Arg", "CGC" => "Arg", "CGA" => "Arg", "CGG" => "Arg",
	"AGU" => "Ser", "AGC" => "Ser", "AGA" => "Arg", "AGG" => "Arg",
    "GGU" => "Gly", "GGC" => "Gly", "GGA" => "Gly", "GGG" => "Gly"
)
"""
sc(s)
```

For convenience scientists often use one letter abbreviations of the amino acids
as defined by
[IUPAC](https://en.wikipedia.org/wiki/International_Union_of_Pure_and_Applied_Chemistry)
and displayed below.

```jl
s = """
# aa - amino acid,
# iupac - International Union of Pure and Applied Chemistry
aa2iupac = Dict(
    "Ala" => "A", "Arg" => "R", "Asn" => "N", "Asp" => "D",
    "Cys" => "C", "Gln" => "Q", "Glu" => "E", "Gly" => "G",
    "His" => "H", "Ile" => "I", "Leu" => "L", "Lys" => "K",
    "Met" => "M", "Phe" => "F", "Pro" => "P", "Ser" => "S",
    "Thr" => "T", "Trp" => "W", "Tyr" => "Y", "Val" => "V",
    "Stop" => "Stop"
)
"""
sc(s)
```

So as a final touch rewrite the amino acid sequence using the one-letter
abbreviations above. As a result you should obtain the following sequence:

```jl
s = """
# AA - amino acids
expectedAAseq = "MALWMRLLPLLALLALWGPDPAAAFVNQHLCGSHLVEAL" *
	"YLVCGERGFFYTPKTRREAEDLQVGQVELGGGPGA" *
	"GSLQPLALEGSLQKRGIVEQCCTSICSLYQLENYCN"
"""
sc(s)
```

## Solution {#sec:translation_solution}

Let's start as we did before by checking the file size.

```jl
s = """
#in 'code_snippets' folder use "./translation/mrna_seq.txt"
#in 'translation' folder use "./mrna_seq.txt"
filePath = "./code_snippets/translation/mrna_seq.txt"
filesize(filePath)
"""
sco(s)
```

OK, it's less than 1 KiB. Let's read it and get a preview of the data.

```jl
s = """
mRna = open(filePath) do file
	read(file, Str)
end
mRna[1:60]
"""
sco(s)
```

It looks good, no spaces between the letters, no newline (`\n`) characters (we
removed them previously in @sec:transcription_solution).

The only issue with `mRna` is that `codon2aa` dictionary contains the codons
(keys) in uppercase letters. All we need to do is to uppercase the letters in
`mRna` using Julia's function of the same name.

```jl
s = """
mRna = uppercase(mRna)
mRna[1:5]
"""
sco(s)
```

OK, time to start the translation. First let's translate a triplet of nucleotide
bases (aka codon) to an amino acid.

```jl
s = """
# translates codon/triplet to amino acid IUPAC
function getAA(codon::Str)::Str
    @assert length(codon) == 3 "codon must contain 3 nucleotide bases"
    aaAbbrev::Str = get(codon2aa, codon, "???")
    aaIUPAC::Str = get(aa2iupac, aaAbbrev, "?")
    return aaIUPAC
end
"""
sc(s)
```

The function is rather simple. It accepts a codon (like `"AUG"`), next it
translates a codon to an amino acid (abbreviated with 3 letters) using
previously defined `codon2aa` dictionary. Then the 3-letter abbreviation is
coded with a single letter recommended by IUPAC (using `aa2iupac` dictionary).
If at any point no translation was found `"?"` is returned.

Now, time for translation.

```jl
s = """
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
        if aa == "Stop"
            break
        end
        aas[aaInd] = aa
    end
    return join(aas)
end
"""
sc(s)
```

We begin with some checks for the sequence. Then, we define the vector `aas`
(`aas` - amino acids) holding our result. We initialize it with empty strings
using `fill` function. We will assign the appropriate amino acids to `aas` based
on the `aaInd` (`aaInd` - amino acid index) which we increase with every
iteration (`aaInd += 1`). In `for` loop we iterate over each consecutive index
with which a triple begins (`1:3:len` will return numbers as `[1, 4, 7, 10, 13,
...]`). Every consecutive `codon` (3 nucleotic bases) is obtained from
`mRNASeq` using indexing by adding `+2` to the index that starts a triple (e.g.
for i = 1, the three bases are at positions 1:3, for i = 4, those are 4:6,
etc.). The `codon` is used to obtain the corresponding amino acid (`aa`) with
`getAA`. If the `aa` is a so-called stop codon, then we immediately `break` free
of the loop. Otherwise, we insert the `aa` to the appropriate place [`aaInd`] in
`aas`. In the end we collapse the vector of strings into one long string with
`join`. It is as if we used the string concatenation operator `*` on each
element of `aas` like so `aas[1] * aas[2] * aas[3] * ...`. Notice, that e.g.
`"A" * ""` or `"A" * "" * ""` is still `"A"`. This effectively gets rid of any
empty `aas` elements that remained after reaching `aa == "Stop"` and `break`
early.

Let's see does it work.

```jl
s = """
protein = translate(mRna)
protein == expectedAAseq
"""
sco(s)
```

Congratulations! You have successfully synthesized pre-pro-insulin, a product
transformed into a hormon that saved many a live. It could be only a matter of
time before you achieve something greater still.

The above (`translate`) is not the only possible solution. For instance, if you
are a fan of [functional
programming](https://en.wikipedia.org/wiki/Functional_programming) paradigm you
may try something like.

```jl
s = """
import Base.Iterators.takewhile as takewhile

function translate2(mRnaSeq::Str)::Str
    len::Int = length(mRnaSeq)
    @assert len % 3 == 0 "the number of bases is not a multiple of 3"
    ranges::Vec{UnitRange{Int}} = map(:, 1:3:len, 3:3:len)
    codons::Vec{Str} = map(r -> mRnaSeq[r], ranges)
    aas::Vec{Str} = map(getAA, codons)
    return takewhile(aa -> aa != "Stop", aas) |> join
end
"""
sc(s)
```

We start by defining `ranges` that will help us get particular `codons` in
the next step. For that purpose you take two sequences for start and end of a
codon and glue them together with `:`. For instance `map(:, 1:3:9, 3:3:9)`
roughly translates into `map(:, [1, 4, 7], [3, 6, 9])` which yields
`[1:3, 4:6, 7:9]`, i.e. a vector of `UnitRange{Int}`. A `UnitRange{Int}` is a
range composed of `Int`s separated by one unit, so by 1, like in `4:6` (`[4, 5,
6]` after expansion) mentioned above. Next, we map over those ranges and use
each one of them (`r`) to get (`->`) a respective codon (`mRnaSeq[r]`). Then, we
map over the `codons` to get respective amino acids (`getAA`). Finally, we move
from left to right through the amiono acids (`aas`) vector and take its elements
(`aa`) as long as they are not equal `"Stop"`. As the last step, we collapse the
result with `join` to get one big string.

```jl
s = """
protein2 = translate2(mRna)
expectedAAseq == protein2
"""
sco(s)
```

Works as expected. The functional solution (`translate2`) often has fewer lines
of code (8 vs 17 for `translate2` and `translate`, respectively). It also
consists of a series of consecutive logical steps, which is quite nice. However,
for a beginner (or someone that doesn't know this paradigm well) it appears more
enigmatic (and therefore off-putting). Moreover, in general it is expected to be
a bit slower than the more imperative for loop version (`translate`). This
should be evident with long sequences [try
`BenchmarkTools.@benchmark translate($mRna^20)` vs
`BenchmarkTools.@benchmark translate2($mRna^20)` in the
REPL (type it after `julia>` prompt)].

> Note. `$` (see above) is an interpolation of global variable recommended [by
> the package](https://juliaci.github.io/BenchmarkTools.jl/stable/). On the
> other hand, `^`, (again see above) replicates a string `n` times, e.g. `"ab" ^
> 3` = `"ababab"`. Interestingly, although `translate(mRna^20)` and
> `translate2(mRna^20)` receive a strand of RNA 20 times longer than `mRna` they
> still return the same amino acid sequence as before. Test yourself and explain
> why. This will also help you realize why `translate2` is slower than its
> counterpart.

In the said case (with `mRna^20`) the difference between $\approx 27\ [\mu s]$
and $\approx 140\ [\mu s]$ (on my laptop) shouldn't be noticeable by a human
($140\ [\mu s]$ is less than 1/1'000th of a second). Therefore, if the
performance is acceptable you may want to go with the functional version.

Anyway, both @sec:transcription and @sec:translation were inspired by the
lecture of [this ResearchGate
entry](https://www.researchgate.net/publication/16952023_Sequence_of_human_insulin_gene)
based on which the DNA sequence was obtained (`dna_seq_template_strand.txt` from
@sec:transcription).
