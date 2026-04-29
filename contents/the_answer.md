# The Answer {#sec:the_answer}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/the_answer)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:the_answer_problem}

In one of the novels of Douglas Adams a supercomputer was asked to provide [the
Answer to the Ultimate Question of Life, the Universe, and
Everything](https://en.wikipedia.org/wiki/Phrases_from_The_Hitchhiker%27s_Guide_to_the_Galaxy#The_Answer_to_the_Ultimate_Question_of_Life,_the_Universe,_and_Everything_is_42).
The answer turned out to be 42. At first it seems to make no sense until you
realize that the ultimate question was: "What do you get if you multiply six by
nine?".

So here is a task for you: modify `dec2bin` function from @sec:binary and name
it, e.g. `dec2baseN`. Use the latter to test numerical systems of the base 2
([binary](https://en.wikipedia.org/wiki/Binary_number)) to 16
([hexadecimal](https://en.wikipedia.org/wiki/Hexadecimal)) and see which numbers
multiplied by each other give 42. Check if both the question and the answer make
sense in any of the different [positional number
systems](https://en.wikipedia.org/wiki/Positional_notation).

## Solution {#sec:the_answer_solution}

OK, we'll start by defining a few constants that will be useful later on.

```jl
s = """
CHARS = vcat('0':'9', 'a':'f') # vcat - vector concatenate
MIN_BASE = 2
MAX_BASE = 16
"""
replace(sc(s), "CHARS" => "const CHARS", "MIN_BASE" => "const MIN_BASE", "MAX_BASE" => "const MAX_BASE")
```

`CHARS` contains symbols used to denote numbers in different positional number
systems. In the binary numeral system (`MIN_BASE = 2`) we use the first two
characters (`CHARS[1:2]`, i.e. `'0' and '1'`) to code a number. In the base-3
system we use the first three characters, i.e. `CHARS[1:3]`, i.e.
`'0', '1', '2'`. Next, the first four, five, six and so forth characters up
until the hexadecimal numeral system (`MAX_BASE = 16`) where we use them all.

Now, for the converter:

```jl
s = """
function dec2baseN(dec::Int, n::Int)::Str
    @assert MIN_BASE <= n <= MAX_BASE "n not in [$MIN_BASE - $MAX_BASE]"
    @assert 0 <= dec <= 1024 "dec must be in range [0-1024]"
    result::Str = ""
    while dec != 0
		# (dec % n) - C-like indexing [0 - (n-1)]
        result *= CHARS[(dec % n) + 1]
        dec = div(dec, n)
    end
    return isempty(result) ? "0" : reverse(result)
end
"""
sc(s)
```

Here, we used an algorithm that differs from to the one in @sec:binary_solution.
Basically, we divide a decimal number (`dec`) by the base `n` in which it is to
be coded. Our algorithm comes from [the
Wikipedia](https://en.wikipedia.org/wiki/Binary_number#Decimal_to_binary) and
although it was designed for a decimal to binary conversion it works also for
other numerical systems. The page in the link states:

> To convert from a base-10 integer to its base-2 (binary) equivalent, the
> number is divided by two. The remainder is the least-significant bit. The
> quotient is again divided by two; its remainder becomes the next least
> significant bit.

Of course, instead of `2` we used a reminder of `n` and the quotient divided by
`n` (`div(dec, n)`). Of note the modulo operator (`%`) returns the reminder in
the range `[0 - (n-1)]`, e.g.

```jl
s = """
[i % 3 for i in 0:6]
"""
sco(s)
```

Therefore, in order to convert it to Julia's indexing system we had to add `+1`.
Moreover, during the turnovers of our `while` loop the least significant
reminder was appended (`*=`) to the `result`, then the second least significant,
then the third, etc. Due to this process the least significant slot was on the
left side of the string (`result`), whereas the most important slot was on the
right side of it. Hence, we `reverse`d the `result` in our last step.

Let's compare its action against Julia's built-ins (the `string` function):

```jl
s = """
[dec2baseN(i, b) == string(i, base=b)
	for b in MIN_BASE:MAX_BASE for i in 0:1024] |> all
"""
sco(s)
```

Nothing to complain about. And now for the answer:

```
for base in MIN_BASE:MAX_BASE
    for dec1 in 0:(base-1), dec2 in 0:(base-1) # 1 digit nums only
        n1 = dec2baseN(dec1, base)
        n2 = dec2baseN(dec2, base)
        product = dec2baseN(dec1 * dec2, base)
        if product == "42"
            println("base $base: $n1 * $n2 = $product")
        end
    end
end
```

```
base 7: 5 * 6 = 42
base 7: 6 * 5 = 42
base 10: 6 * 7 = 42
base 10: 7 * 6 = 42
base 12: 5 * a = 42
base 12: a * 5 = 42
base 13: 6 * 9 = 42
base 13: 9 * 6 = 42
base 16: 6 * b = 42
base 16: b * 6 = 42
```

So it seems that by multiplying the above two single digit numbers in bases: 7,
10, 12, 13, and 16 we get 42 as a result. Of the above only base 13 fulfills the
criteria of both the question and the answer.

If you feel that doing the multiplication in decimal and translating it to
`product` in the desired base system was like cheating, then you may try to
re-implement `add` and `multiply` functions from @sec:binary_solution. A natural
way to do that would be to create an addition table for `add(num1::Char,
num2::Char, base::Int)::Tuple{Char, Char}` and a multiplication table for
`multiply(num1::Char, num2::Char, base::Int)::Tuple{Char, Char}` to use. Thanks
to them the functions would rely on the same process as longhand pen and paper
calculations. Unfortunately, nobody taught us addition and multiplication tables
in numerical systems of other bases when we were in school. And so, again, the
easiest way to create such tables would be to use conversion from decimals. For
that reason, here I will stay with the solution presented above. Still, you may
check [the code snippets for this
chapter](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/the_answer)
as they contain the other method (or better try to implement it yourself).
