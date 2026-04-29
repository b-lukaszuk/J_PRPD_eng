# Caesar {#sec:caesar}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/caesar)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:caesar_problem}

We finished the previous chapter (see @sec:shift_solution) by stating that the
file `trarfvf.txt` contains a text coded with a substitution cipher
with the shift (rotation) of 13 characters. This turns out to be the
[Caesar cipher](https://en.wikipedia.org/wiki/Caesar_cipher) used by the famous
Roman emperor in antiquity (breaking the cipher without a computer program and
sufficient amount of text is not an easy task).

So here is an exercise for you, write a computer program that can code and
decode a textual message with a substitution cipher of any shift. Use it to
decrypt the message contained in `trarfvf.txt` (~31 KiB). Feel free to decipher
the file name (`trarfvf`) itself as well.

## Solution {#sec:caesar_solution}

Let's start by writing a function that will create alphabets for the outer and
inner rings of the discs from @fig:codingDiscs2.

![Coding Discs. The outer disc contains the original alphabet. The inner disc
contains the alphabet shifted by 2
characters](./images/codingDiscs.png){#fig:codingDiscs2}

```jl
s = """
function getAlphabets(rotBy::Int, upper::Bool)::Tuple{Str, Str}
	alphabet::Str = upper ? join('A':'Z') : join('a':'z')
	rot::Int = abs(rotBy) % length(alphabet)
	rotAlphabet::Str = alphabet[(rot+1):end] * alphabet[1:rot]
	return rotBy < 0 ? (rotAlphabet, alphabet) : (alphabet, rotAlphabet)
end
"""
sc(s)
```

First we create an alphabet made of `'a'` to `'z'` letters with the desired
casing (`upper`) using a
[StepRange](https://docs.julialang.org/en/v1/base/collections/#Base.StepRange)
(`'a':'z'` or `'A':'Z'`) that we `join` into a string. Next, we use [modulo
operator](https://docs.julialang.org/en/v1/base/math/#Base.rem) (`%` - returns
reminder of a division) to get the desired rotation (`rot`). This allows us to
gracefully handle the overflow of `rotBy` [e.g. when `rotBy` is 28 and
`length(alphabet)` is 26 we get `28 % 26`i.e. `2` (full circle turn + shift by 2
fields)]. Then we create the rotated alphabet (`rotAlphabet`) starting at
`(rot+1)` and appending (`*`) the beginning of the normal `alphabet`. Finally,
if `rotBy` is negative (`rotBy < 0`, decrypting the message) we return
`rotAlphabet` and `alphabet` to be used as outer and inner disc in
@fig:codingDiscs2, respectively. Otherwise `alphabet` lands in the outer ring
and 'rotAlphabet' in the inner one (encrypting a message).

Time for a simple test.

```jl
s = """
Dict(i => getAlphabets(i, true) for i in -1:1:1)
"""
sco(s)
```

Appears to be working as intended. Now, even a greatest journey begins with a
first step. Therefore, in order to encode any text we need to be able to encode
a single character.


```jl
s = """
function codeChar(c::Char, rotBy::Int)::Char
	outerDisc::Str, innerDisc::Str = getAlphabets(rotBy, isuppercase(c))
	ind::Union{Int, Nothing} = findfirst(c, outerDisc)
	return isnothing(ind) ? c : innerDisc[ind]
end
"""
sc(s)
```

We begin by obtaining `outerDisc` and `innerDisc` with `getAlphabets` that we
just created. Next, we search for the index (`ind`) of the character to encode
(`c`) in the `outerDisc`. The search may fail (e.g. no `,` in an alphabet) so
`ind` can be either `nothing` (value `nothing` of type `Nothing` indicates a
failure) or an integer hence the type of `ind` is `Union{Int, Nothing}` to
depict just that. Finally, if the search failed (`isnothing(ind)`) we just
return `c` as it was, otherwise we return the encoded letter read from the inner
ring (`innerDisc[ind]`). Observe.

```jl
s = """
(
	codeChar('a', 1),
	codeChar('A', 2),
	codeChar(',', 2)
)
"""
sco(s)
```

Once we know how to code a character, time to code a string.

```jl
s = """
# rotBy > 0 - encrypting, rotBy < 0 - decrypting, rotBy = 0 - same msg
function codeMsg(msg::Str, rotBy::Int)::Str
	coderFn(c::Char)::Char = codeChar(c, rotBy)
	return map(coderFn, msg)
end
"""
sc(s)
```

And voila. Notice, that first we created `coderFn`, which is a function ([single
expression
function](https://en.wikibooks.org/wiki/Introducing_Julia/Functions#Single_expression_functions))
inside of a function (`codeMsg`). Now we can neatly use it with `map`.

OK, time to decipher our enigmatic message (remember that in @sec:shift_solution
we figured out that the shift is equal 13).

```jl
s = """
# be sure to adjust the path
# the file's size is roughly 31 KiB
codedTxt = open("./code_snippets/shift/trarfvf.txt") do file
	read(file, Str)
end

decodedTxt = codeMsg(codedTxt, -13)
"<<" * first(decodedTxt, 54) * ">>"
"""
sco(s)
```

Hmm, it looks suspiciously like the first phrase from the Bible.

```jl
s = """
codeMsg("trarfvf", -13)
"""
sco(s)
```

And indeed, even the file name indicates that it is (a part of) the Book of
Genesis.

We could stop here or try to improve our solution a bit.

Let's try to define `getEncryptionMap` that will be an equivalent of our
`getAlphabets`.

```jl
s = """
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
"""
sc(s)
```

The function is pretty similar to the one previously mentioned, except for the
fact that it returns a dictionary with the alphabet on the outer disc being the
keys and the letters on the inner disc are its values (compare with
@fig:codingDiscs2). Moreover, the map contains both lower- and upper-case
characters.

Time to code a character.

```jl
s = """
function code(c::Char, encryptionMap::Dict{Char, Char})::Char
    return get(encryptionMap, c, c)
end
"""
sc(s)
```

To that end we used the built in `get` function that looks for a character (`c`,
`get`'s second argument) in `encryptionMap`, if the search failed it returns the
character as a default value (`c`, `get`'s third argument).

Finally, let's code the message.

```jl
s = """
function code(msg::Str, rotBy::Int)::Str
    encryptionMap::Dict{Char, Char} = getEncryptionMap(rotBy)
    coderFn(c::Char)::Char = code(c, encryptionMap)
    return map(coderFn, msg)
end
"""
sco(s)
```

Notice, that we defined two different versions (aka methods) of `code`
function. Julia will choose the right one during the invocation based on the
type of the arguments.

Time for a test.

```jl
s = """
codeMsg(codedTxt, -13) == code(codedTxt, -13)
"""
sco(s)
```

Works the same, still in the above case `codeMsg(codedTxt, -13)` takes tens of
milliseconds to execute, whereas `code(codedTxt, -13)` only hundreds of
microseconds (on my laptop). The human may not tell the difference, but we
obtained some 50x speedup thanks to the faster lookups in dictionaries
(sometimes called hash maps in other programming languages) and the fact that we
do not generate our discs anew for every letter we code.
