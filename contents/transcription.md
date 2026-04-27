# Transcription {#sec:transcription}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/transcription)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:transcription_problem}

The genetic material of an eucariotic cell is located in its nucleus in the form
of a nucleic acid ([DNA](https://en.wikipedia.org/wiki/DNA) to be precise). At
one point DNA fragments serve as matrices to produce proteins that build our
bodies and perform some actions within it (e.g. like hormones or enzymes). Such
a transformation takes two steps called
[transcription](https://en.wikipedia.org/wiki/Transcription_(biology)) and
[translation](https://en.wikipedia.org/wiki/Translation_(biology)).

During the first process, DNA's double helix is unwind and one of the strands
(called template strand) is rewritten to mRNA (hence transcription) according to
the table presented below.

```
 DNA | mRNA
-----+------
 'c' | 'g'
 'g' | 'c',
 'a' | 'u',
 't' | 'a'
```

Here: `a`, `c`, `g`, `t`, `u` are the shortcuts (also written in uppercase) for
the nucleic acids' molecular components (nucleotide bases) called `adenine`,
`cytosine`, `guanine`, `thymine`, and `uracil`.

This time your task is to read the data from the file:
`dna_seq_template_strand.txt` (to be found in [the code snippets for this
chapter](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/transcription)).
The file contains a sequence of nucleotide bases of some gene. Splice its coding
parts (aka. [exons](https://en.wikipedia.org/wiki/Exon)), which encompass the
molecules at positions 2424-2610 and 3397-3542. Transcribe the obtained strand
to an mRNA molecule according to [the complementarity
rule](https://en.wikipedia.org/wiki/Complementarity_(molecular_biology)#DNA_and_RNA_base_pair_complementarity)
presented in the table above.

## Solution {#sec:transcription_solution}

The file `dna_seq_template_strand.txt` is quite small as you can see by using
your file manager or Julia:

```jl
s = """
#in 'code_snippets' folder use "./transcription/dna_seq_template_strand.txt"
#in 'transcription' folder use "./dna_seq_template_strand.txt"
filePath = "./code_snippets/transcription/dna_seq_template_strand.txt"
filesize(filePath)
"""
sco(s)
```

Here we defined `filePath` to our file. Next, we checked its size with
[filesize](https://docs.julialang.org/en/v1/base/file/#Base.filesize) to see it
is equal to `jl filesize(filePath)` bytes. This is slightly more than
 `jl round(Int, filesize(filePath) / 1024)` kilobytes (KiB). Such a small file
can be easily swallowed by
[read](https://docs.julialang.org/en/v1/base/io-network/#Base.read) (the
recommended way below) and returned as a one long `Str` (type alias for
`String`).

```jl
s = """
dna = open(filePath) do file
	read(file, Str)
end
dna[1:75]
"""
replace(sco(s), Regex("\ncggtcccac") => "\\\\ncggtcccac")
```

> Note. For large files you should probably read it line by line with something
> like `for line in eachline(file) #do sth with line# end` or use a dedicated
> library.

The nucleotide bases (`a`, `c`, `t`, `g`) are grouped by 10. Moreover, notice
the `\n` character on the right. It is a
[newline](https://en.wikipedia.org/wiki/Newline) character that tells the
computer to print the subsequent characters from the beginning of a new line. We
need to splice sequence at positions 2424-2610 and 3397-3542 so let's get rid of
those extra characters to make the counting easier.

```jl
s = """
dna = replace(dna, " " => "", "\n" => "")
dna[1:75]
"""
replace(sco(s), Regex("\n\" => ") => "\\n\" => ")
```

This couldn't be simpler, we just use `replace` and `itIs => shouldBe` syntax.
The spaces (`" "`) are replaced with nothing (`""`, empty string) and newlines
(`"\n"`) with nothing (`""`, empty string) as well. Effectively this removed
them from our `dna` string.

String splicing is easily done with indexing (if we got only
[ASCII](https://en.wikipedia.org/wiki/ASCII) characters) and string
concatenation operator (`*`) like so.

```jl
s = """
dnaExonsOnly = dna[2424:2610] * dna[3397:3542]
dnaExonsOnly[1:75]
"""
sco(s)
```

All that's left to do is to transcribe to mRNA using the complementarity rule
mentioned above. First, let's rewrite it to Julia's
[dictionary](https://b-lukaszuk.github.io/RJ_BS_eng/julia_language_decision_making#sec:julia_language_dictionaries).

```jl
s = """
dna2mrna = Dict(
    'a' => 'u',
    'c' => 'g',
    'g' => 'c',
    't' => 'a'
)
"""
sc(s)
```

And now the transcription itself.

```jl
s = """
function transcribe(nucleotideBase::Char,
    complementarityMap::Dict{Char, Char}=dna2mrna)::Char
    return get(complementarityMap, nucleotideBase, '?')
end

(
	transcribe('a'),
	transcribe('g'),
	transcribe('x')
)
"""
sco(s)
```

Our transcribe function takes a character (`Char`, `String` is build of
individual characters) called `nucleotideBase` and a default
`complementarityMap` set to `dna2mrna`. It uses `get` to return a complementary
base to `nucleotideBase` (its second argument) or a default (its third argument,
in this case just return `'?'`) if a match was not found.

All that's left to do is to write a `transcribe` function for the whole string
(`dnaExonsOnly`).

```jl
s = """
function transcribe(dnaSeq::Str)::Str
    return map(transcribe, dnaSeq)
end

mRna = transcribe(dnaExonsOnly)
(
	dnaExonsOnly[1:10],
	mRna[1:10]
)
"""
replace(sco(s), Regex(", \"") => "\n \"")
```

Here a map function applies previously defined `transcribe` on every character
of `dnaSeq` and glues the obtained characters into a string.

Instead of the above two functions we could have just written

```jl
s = """
mRna = map(base -> get(dna2mrna, base, base), dnaExonsOnly)
(
	dnaExonsOnly[1:10],
	mRna[1:10]
)
"""
replace(sco(s), Regex(", \"") => "\n \"")
```

with the same result, but I felt that the longer version was clearer.

Finally, let's just check if the transcription produced no artifacts (`'?'`
defined before).

```jl
s = """
findfirst(base -> base == '?', mRna) |> isnothing
"""
sco(s)
```

Everything seems to be in order.
