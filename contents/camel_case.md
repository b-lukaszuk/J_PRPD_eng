# Camel Case {#sec:camel_case}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or
with [the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/camel_case)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:camel_case_problem}

In programming there are a few different types of naming conventions, the two
most popular of them are:
[smallCamelCase](https://en.wikipedia.org/wiki/Camel_case) and
[snake_case](https://en.wikipedia.org/wiki/Snake_case).

At times it is useful to quickly convert from one of them to the other (hence
such a functionality is sometimes found in
[IDEs](https://en.wikipedia.org/wiki/Integrated_development_environment)).

Here is a task for you. Write two functions with the following signatures:

```
changeToCamelCase(snakeCasedWord::Str)::Str
```

and

```
changeToSnakeCase(camelCasedWord::Str)::Str
```

The functions should perform the conversion as specified in this template:

```
"hello_world" <=> "helloWorld"
"nice_to_meet_you" <=> "niceToMeetYou"
"translate_to_english" <=> "translateToEnglish"
```

You may assume that the input is well formatted and contains only the
underscores ("_") and the characters from the Latin alphabet.

## Solution {#sec:camel_case_solution}

One of the most succinct (and quite performant) solutions would be based on
[regular expressions](https://en.wikipedia.org/wiki/Regular_expression) (also
called regexes). Julia does have a regex support (see [the
docs](https://docs.julialang.org/en/v1/base/strings/#Base.Regex)) and we will
explore this venue in @sec:regex_problem. For now, in order to keep things
simple our approach will rely on good old for loops and conditionals.

First `changeToSnakeCase` as it is simpler to write (start small and build).

```jl
s = """
function changeToSnakeCase(camelCasedWord::Str)::Str
    result::Str = ""
    for c in camelCasedWord
        result *= isuppercase(c) ? '_' * lowercase(c) : c
    end
    return result
end
"""
sc(s)
```

We begin with an empty `result`. Next, we travel through each character (`c`) of
our `camelCasedWord` if a letter is uppercased (`isuppercase(c) ?`) we update
our result (`*=`) by appending to it underscore (`'_'`) concatenated (`*`) with
the lowercased character (`lowercase(c)`). Otherwise (`:`) we append the
character unchanged (`c`). Finally, we `return` the `result`.

Let's see if it works.

```jl
s = """
map(changeToSnakeCase, ["helloWorld",
	"niceToMeetYou", "translateToEnglish"])
"""
sco(s)
```

Looks good. Time for the other function.

```jl
s = """
function changeToCamelCase(snakeCasedWord::Str)::Str
    result::Str = ""
    prevUnderscore::Bool = false
    for c in snakeCasedWord
        if c == '_'
            prevUnderscore = true
            continue
        else
            result *= prevUnderscore ? uppercase(c) : c
            prevUnderscore = false
        end
    end
    return result
end
"""
sc(s)
```

One more time, we begin with an empty result (`result::Str = ""`), but this time
we also declare an indicator that tells us whether the previously examined
letter was an underscore (`prevUnderscore`). Next, we traverse the
`snakeCasedWord` character by character (`for c in snakeCasedWord`) and build up
the result. If the currently examined character is an underscore (`if c == '_'`)
we set the indicator to true and skip rest of the code in the for loop (in this
iteration only) with
[continue](https://docs.julialang.org/en/v1/base/base/#continue). Otherwise
(`else`), we append the character to the result (`result *=`) with the proper
casing based on the value of `prevUnderscore` and set this last variable to
`false`. Once we're done, we `return` the `result`.

Time for another test.

```jl
s = """
map(changeToCamelCase,
    ["hello_world", "nice_to_meet_you", "translate_to_english"])
"""
sco(s)
```

And another small victory.
