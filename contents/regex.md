# Regex {#sec:regex}

In this chapter I used the following libraries.

```jl
s2 = """
import Random as Rnd # internal library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/regex)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:regex_problem}

### Regex Intro {#sec:regex_problem_intro}

> **_Note:_** This subsection provides a short description of regular
> expressions. You may skip it if you know what a regex is. In that case go to
> the task specification right away (see @sec:regex_problem_tasks).

Imagine you work at a police station that happened to arrest a John Smith who is
a suspect in a certain case. In your country the identity of an accused person
is to be protected from public, so your job is to obfuscate any mention of him
from the press release.

```jl
s = """
function getTxtFromFile(filePath::Str)::Str
    fileTxt::Str = ""
    try
        fileTxt = open(filePath) do file
            read(file, Str)
        end
    catch
        fileTxt = "Can't read '\$filePath'. Make sure it exists."
    end
    return fileTxt
end

txt = getTxtFromFile("./code_snippets/regex/loremJohnSmith.txt")
"<<< " * txt[1:200] * " ... >>>"
"""
replace(sco(s), "./code_snippets/regex/loremJohnSmith.txt" => "./loremJohnSmith.txt")
```

This could be done, e.g. by replacing his last name with its first letter, but
it's kind of tedious and boring to do this manually while reading the text. It
may be sped up with a [word processing
program](https://en.wikipedia.org/wiki/List_of_word_processor_programs) in which
`Ctrl+F` is usually a shortcut for a `find` command. In Julia this could be done
with [eachmatch](https://docs.julialang.org/en/v1/base/strings/#Base.eachmatch)
like so:

```jl
s = """
function getAllMatches(rmi::Base.RegexMatchIterator)::Vec{Str}
    return [regMatch.match for regMatch in rmi]
end

getAllMatches(eachmatch(r"John Smith", txt))[1:2]
"""
sco(s)
```

Here we defined a little function (`getAllMatches`), that will help us to
extract the matches as a vector of strings, which is easier to read than the
default structure returned by `eachmatch`. Notice, the `r"John Smith"` argument
in `eachmatch`. The `r` indicates that the following characters compose no
ordinary string, but a special one that is called a [regular
expression](https://en.wikipedia.org/wiki/Regular_expression) (or regex). It may
not seem like much right now, but we'll see its potential in a moment.

Once we confirmed the phrase existence we may wish to obfuscate it. Again, in a
word processing program this could be done with `Ctrl+H` that usually stands for
`find and replace` command. In Julia, we would do it with something like:

```
# in Julia strings are immutable
# to make changes permament write it to `txt` and/or to a file
txt = replace(txt, r"John Smith" => "John S")
eachmatch(r"John Smith", txt) |> getAllMatches
```

```
String[]
```

There, we did our job, the identity of an accused person is protected. We may
write the file on a disk and send the press report. I imagine now you're
wondering what's the big deal with those regexes anyway. For a person with basic
computer literacy what we've done doesn't seem particularly advanced. Well,
you're right. It it not. That's because in order **to have a regex we need to
use some meta-characters, i.e. special symbols that are interpreted beyond their
literal meaning. On the other hand, as a general rule, any letter or digit in
regex (like `r"John Smith"`) stands for itself**. Overall, the list of
meta-characters is rather long, but as stated in [the
docs](https://docs.julialang.org/en/v1/manual/strings/#man-regex-literals) it
may be found at [the PCRE2 syntax
manpage](https://www.pcre.org/current/doc/html/pcre2syntax.html).

Instead of going through all the meta-characters (admittedly an impossible task
for a short book chapter) let me just demonstrate a few of the more important
ones with some illustrative examples.

#### Example 1

```jl
s = """
txt = getTxtFromFile("./code_snippets/regex/loremDates.txt")
"<<< " * txt[1:200] * " ... >>>"
"""
replace(sco(s), "./code_snippets/regex/loremDates.txt" => "./loremDates.txt")
```

This time, since I study for an exam, my `txt` contains a passage from a history
book. I would like to extract the dates from it to make sure I know them
all. Let's say that the dates cover years between 1000 AD and the present.
Doing a standard string search is no good, after all I would have to check like
a thousand numbers. But wait, a simple regex can save me a lot of work. Observe:

```jl
s = """
eachmatch(r"[0-9][0-9][0-9][0-9]", txt) |> getAllMatches
"""
sco(s)
```

This returned all 4-digit sets in the order they appear in the text (left to
right, top to bottom).

In the regex (`r"..."`), the `[...]` is a positive character class that matches
any of the enclosed characters. Therefore, `[0123456789]` would mean match any
character used to represent a digit (`0` or `1` or `2` or ...). In general the
contents of a positive character class are interpreted literally with the
exception of `\`, `^` at the beginning, and `-` between two characters. In the
last case, the hyphen (`-`) means any character within a range. Typically its
used in the following configurations: `[0-9]`, `[a-z]`, `[A-Z]`, `[A-z]`, or
`[A-z0-9]`. The range is likely determined based on the underlying codes
(e.g. like [ASCII](https://en.wikipedia.org/wiki/ASCII)). Therefore, if you want
to match any letter (capital or small) the regex must be written as `[A-z]` and
not `[a-Z]`. Anyway, in our case a regex of the form `r"[0-9][0-9][0-9][0-9]"`)
means match a digit (`[0-9]`) followed by a digit (`[0-9]`), followed by a digit
(`[0-9]`), followed by a digit (`[0-9]`) (exactly 4 digits in a row).

Interestingly, we could save ourselves even more typing by using other
meta-characters for this problem, i.e.

```jl
s = """
eachmatch(r"[0-9]{4}", txt) |> getAllMatches
"""
sco(s)
```

The `{4}` means exactly 4 repetitions of a preceding character class (which is
`[0-9]`, so a digit).

Some newer regex engines allow to shorten it even more:

```jl
s = """
eachmatch(r"\\d{4}", txt) |> getAllMatches
"""
sco(s)
```

Where `\d` means any digit (in general `\` gives a special meaning to the
following ordinary character) and `{4}` still designates exactly 4 repetitions
of a previous token.

#### Example 2

```jl
s = """
txt = getTxtFromFile("./code_snippets/regex/loremDollarsDates.txt")
"<<< " * txt[1:200] * " ... >>>"
"""
replace(sco(s), "./code_snippets/regex/loremDollarsDates.txt" => "./loremDollarsDates.txt")
```

This time, we got a text that contains both dollars quota (in `$123` format) and
dates, but we're interested only in the former. Let's say we want to add them up
to find out how much do we need to pay.

First, we'll try to get the numbers out. If we assume for a moment that the
amount of money is at least 3 digits long then for our first try we might go
with:

```
eachmatch(r"\d.+\d", txt) |> getAllMatches
```

```
[
"112 amet consectetur 1234",
"200",
"173 exercitation ullamco 1492",
"1180 Duis aute irure dolor in $122",
"113 cillum dolore eu $3333",
"444 sint occaecat cupidatat non $212",
"534"
]
```

Here `\d` means a digit, `.` is any character (except for newline), and `+`
stands for one or more of the preceding tokens (so match a digit followed by one
or more characters, followed by a digit). There is a small problem though, we
caught more than we wanted. That's because by default, regexes are greedy
(usually they match as much as they can until a line ends). If we want to make
it more temperate we need to follow `.+` with `?` (one or more characters, but
as few as you can to fulfill the condition).

```
eachmatch(r"\d.+?\d", txt) |> getAllMatches
```

```
[
"112",
"123",
"200",
"173",
"149",
"118",
"0 Duis aute irure dolor in \$1",
"113",
"333",
"444",
"212",
"534"
]
```

An improvement, but we're still not there. Let's try again.

```
eachmatch(r"\d{1,}", txt) |> getAllMatches
```

```
[
"112"
"1234"
"200"
"173"
"1492"
"1180"
"122"
"113"
"3333"
"444"
"212"
"534"
]
```

Pretty good, here `{i,j}` means between `i` and `j` (inclusive - inclusive)
occurrences of the previous token (`\d`). `{,j}` stands for 0 to `j` and `{i,}`
stands for `i` or more. Therefore, we only match 1 or more digits in a row, so
it seems that we are finally there. Well, not quite, right now we got no way to
tell which digits denote money and which years (they're from the file
`loremDollarsDates.txt`).

> **_Note:_** You need to be precise while typing the quantifiers. Typing
> `eachmatch(r"\d{1, }", txt) |> getAllMatches` (it contains an extra space in
> `\d{1, }`) will give you no matches (empty vector).

Let's try to change our regex a bit to extract only dollars.

```
eachmatch(r"$\d{1,}", txt) |> getAllMatches
```

```
String[]
```

Hmm, we wanted to extract a dollar symbol `$` with all the following digits.
Oddly enough that seemed to have failed. That's because `$` is a meta-character
that denotes end of a subject (usually end of a line or end of a string). So,
actually what we said with `$\d{1,}` was: find digits after the end of a
string. An impossible task, hence the empty vector as a result. If we want `$`
to be interpreted as a regular dollar symbol we need to proceed it with `\` (`\`
gives a special meaning to an ordinary character, like in `\d,` and strips it
away from a special character like `$`).

```
eachmatch(r"\$\d{1,}", txt) |> getAllMatches
```

```
[
"$112",
"$200",
"$173",
"$1180",
"$122",
"$113",
"$3333",
"$444",
"$212",
"$534"
]
```

Finally, we can add it up using, e.g. this few liner:

```
eachmatch(r"\$\d{1,}", txt) |> getAllMatches |>
vecStrDollars -> replace.(vecStrDollars, "\$" => "") |>
vecStrNumbers -> parse.(Int, vecStrNumbers) |>
sum
```

```
6423
```

And voila, we're done. Notice, however, that the regex isn't perfect. For
example, it doesn't handle correctly the amounts of money that contain floating
point values (or negative quotas). If that were the requirement, we would would
have to improve upon it.

#### Example 3

This time we got a few random telephone numbers.

```jl
s = """
Rnd.seed!(9)
telNums = [join(Rnd.rand(string.(0:9), 9)) for _ in 1:3]
"""
sco(s)
```

Our task is to convert them into a more readable form, e.g. xxx-xxx-xxx.

```
replace.(telNums, r"(\d{3})(\d{3})(\d{3})" => s"\1-\2-\3")
```

```
[
	"304-039-945",
	"545-946-090",
	"818-309-467"
]
```

The new elements here are `()` and `\1`, `\2`, `\3`. Those are capture groups
and back-references, respectively. Therefore, `(\d{3})` in a regex (`r""`) means
capture any three digits in a row and remember them, whereas `\1` in the
substitution (`s""` - denotes a substitution string that may use
meta-characters) means: use the first captured and remembered group (by analogy
`\2` is for the second captured group and `\3` is for the third).

#### Example 4

In @sec:camel_case we dealt with two-way text transformations between camelCase
and snake_case.

Let's do this with regexes. We'll start with `camelCasedWords`:

```
camelCasedWords = [
	"helloWorld", "niceToMeetYou", "translateToEnglish"
]

eachmatch.(r"([A-Z])", camelCasedWords) .|> getAllMatches
```

```
[
	["W"],
	["T", "M", "Y"],
	["T", "E"]
]
```

First, we capture (`()`) any capital letter (`[A-Z]`) in a string. Now we would
like to lowercase it. Per [pcre2 syntax
manual](https://www.pcre.org/current/doc/html/pcre2syntax.html#SEC32) we should
be able to do this using `\l` escape sequence (it means lowercase next
character), but for whatever reason the following snippet throws an error:

```
replace.(camelCasedWords, r"([A-Z])" => s"\l\1")
```

No, biggie. Julia allows the second argument of `replace` to be a
[pair](https://docs.julialang.org/en/v1/base/collections/#Core.Pair) of the form
`regex => function that operates on a matched string`. We can use that to our
advantage:

```
# no need for (), since we don't use backreferences anyway
replace.(camelCasedWords, r"[A-Z]" => lowercase)
```

```
[
"helloworld",
"nicetomeetyou",
"translatetoenglish"
]
```

Almost there, we just need to precede the lower-cased letter with `_`. This
could be done by using an anonymous function, e.g. like this:

```
replace.(camelCasedWords, r"[A-Z]" => AtoZ -> "_" * lowercase(AtoZ))
```

```
[
"hello_world",
"nice_to_meet_you",
"translate_to_english"
]
```

or like that (here we use a template string):


```
replace.(camelCasedWords, r"[A-Z]" => AtoZ -> "_$(lowercase(AtoZ))")
```

```
[
"hello_world",
"nice_to_meet_you",
"translate_to_english"
]
```

Nice.

Now, it's time for the opposite transformation.

```
snakeCasedWords = ["hello_world",
	"nice_to_meet_you", "translate_to_english"
]

replace.(snakeCasedWords, r"_[a-z]" => _atoz -> uppercase(_atoz[2:end]))
# or
replace.(snakeCasedWords,
	r"_[a-z]" => _atoz -> uppercase(strip(_atoz, '_')))
```

```
[
"helloWorld",
"niceToMeetYou",
"translateToEnglish",
]
```

Wow, that felt like a breeze.

Overall, the two lines of code (`replace.(camelCasedWord, etc.)` and
`replace.(snakeCasedWords, etc.)`) are the equivalent of roughly 20 lines of
code in @sec:camel_case_solution. And that's how it usually is, regexes are more
succinct than the traditional functions, although they're not necessarily faster
to write (especially if that is your first encounter with the subject).

#### Summary

Here's a quick reminder of what we learned about regexes and meta-characters:

1. in general any letter or digit that occurs in regex stands for itself;
2. a positive character class is denoted by square brackets and is often used to
   capture a range of characters, like `[a-z]`, `[A-Z]`, `[0-9]`, `[A-z]`, or
   `[A-z0-9]`;
3. `{}` is a quantifier, it specifies a quantity of the previous token, where
   `{i}`, `{i,j}`, `{i,}`, and `{,j}` mean: exactly `i`, between `i` and `j`, at
   least `i` and up-to `j` previous tokens, respectively;
4. `\` bestows a special meaning on an ordinary character (`\d` denotes any
   digit), or strips it away from a special character (`$` - is end of a string,
   wheres `\$` is a dollar
   symbol);
5. `(sth)` inside of `r""` stands for capture and remember, whereas `\1` in
   `s""` denotes back-reference to the first capture;
6. the second argument of replace is a
   [pair](https://docs.julialang.org/en/v1/base/collections/#Core.Pair) of the
   form: `r"" => ""` (regex => regular string), `r"" => s""` (regex =>
   substitution string), `r"" => function` (regex => function that accepts a
   string and returns a string possibly applying some transformations on the
   way).

### Regex Tasks {#sec:regex_problem_tasks}

OK, time to put what you've learned to good use. If, while solving the tasks,
you need a visual assistant that helps you with regular expressions, then you
may try e.g. [regex101](https://regex101.com/).

#### Regex Task 1 {#sec:regex_problem_task1}

You got a series of dates in the US format "MM.DD.YYYY":

```
datesMMDDYYYY = ["01.04.2025", "11.01.2018", "12.31.1999", "03.20.2026"]
```

The format is confusing to some (e.g. European) people. Change it to
a less ambiguous "YYYY-MM-DD" configuration.

#### Regex Task 2 {#sec:regex_problem_task2}

Read the contents of `loremMail.txt` that is to be found in [the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/regex).
It contains random e-mail addresses (with repetitions). Use Julia to list the
unique e-mail addresses found in the text.

#### Regex Task 3 {#sec:regex_problem_task3}

Here's a vector of random names:

```
# random names
names = ["Mary Johnson", "Eve Smith", "Tom Brown"]
```

Swap the names order with a regex ("Adam Smith" should become "Smith, Adam") and
sort them alphabetically in ascending order.

Can you do the same, but while accounting for possible middle names.

```
# random names
names = ["Jane Johnson", "Mary Jane Doe", "Peter Smith", "Adam Tom Brown"]
```

To add a small tweak, I want you to swap the names, abbreviate the middle name
("John Daniel Smith" should become "Smith, John D.", whereas "Adam Smith" should
become "Smith, Adam") and then sort them alphabetically in ascending order.

#### Regex Task 4 {#sec:regex_problem_task4}

In @sec:mortgage_solution we wrote a `fmt` function to format numbers to
something like: "123,456 USD".

Write a program (possibly a regex or regexes + some extra code) that will
convert those numbers to the desired form (place `,` after every three numbers
from right).

```
nums = [0, 1, 12, 123, 1234, 12345,
	123456, 1234567, 12345678, 123456789]
```

Can you modify your program so that it handles the following numbers correctly
as well (e.g. `12345.678` should become "12,345.68 USD"):

```
nums = [0, 0.1, 1, 1.2, 12., 12.34, 123.456,
	1234, 12345, 12345.67, 123456.7, 1234567.89]
```

Well, let's find out. Good luck.

## Solution {#sec:regex_solution}

### Regex Solution 1 {#sec:regex_problem_solution1}

The solution is pretty straightforward if you read through Example 1 and 3 in
@sec:regex_problem_intro.

```
replace.(datesMMDDYYYY, r"(\d{2})\.(\d{2})\.(\d{4})" => s"\3-\1-\2")
```

```
[
"2025-01-04",
"2018-11-01",
"1999-12-31",
"2026-03-20"
]
```

We just go and capture the months (the first pair of digits, `(\d{2})`, followed
by a literal dot, `\.`), the days (second pair of digits, `(\d{2})`, followed by
a literal dot, `\.`) and the years (last four digits, `(\d{4})`). In the
substitution string we reference them back in the appropriate order (`\3`, `\1`,
and `\2`) separated by hyphens (`-`). So, we replaced the whole match
(`(\d{2})\.(\d{2})\.(\d{4})`) with the remembered digits in the right order and
with the right separators (`-`). And that's it. Finito.

### Regex Solution 2 {#sec:regex_problem_solution2}

```jl
s = """
txt = getTxtFromFile("./code_snippets/regex/loremMail.txt")
"<<< " * txt[1:200] * " ... >>>"
"""
replace(sco(s), "./code_snippets/regex/loremMail.txt" => "./loremMail.txt")
```

Surprisingly, it seems that a proper regex for e-mail validation is pretty
complex ([see
here](https://stackoverflow.com/questions/201323/how-can-i-validate-an-email-address-using-a-regular-expression)).
Still, we can go a far way with a much simpler one, which in our particular case
should do the trick:

```
eachmatch(r"[A-z0-9._\-]+@[A-z0-9._\-]+", txt) |> getAllMatches |> unique
```

```
[
	"tom@write2me.com",
	"potential_contact@hello.pl",
	"another.contact@yyy.es",
	"other-potential-contact@hello.pl",
	"eve@write2me.com",
	"eve2@write2me.com"
]
```

The regex is composed of a few parts, but mostly of `[A-z0-9._\-]`. It searches
for:

1) any letter (`A-z`, an email may contain a capital letter, although in
general, they are
[case-insensitive](https://en.wikipedia.org/wiki/Case_sensitivity)), or
2) a digit (`0-9`), or
3) a literal dot (`.` inside a positive character class is just a dot, although
in general inside a regex it stands for any character except for newline), or
4) an underscore (`_`), or
5) a literal hyphen (`\-`, likely we didn't have to precede it with `\` since it
wasn't between other 2 characters).

This positive character class must be repeated at least one time (`+`) before
the `@`, symbol. On the other hand, the `@` symbol must be followed by at least
one (`+`) character class that we already discussed (`[A-z0-9._\-]`). Notice,
that there is no need to add `?`, after the `+` to make a non-greedy match. That
is because the email addresses, are separated by one or more spaces and the
positive character class, (`[A-z0-9._\-]`) does not include spaces.

### Regex Solution 3 {#sec:regex_problem_solution3}

Swapping the names is a piece of cake. We just use capture groups (`(...)`)
that contain one or more (`+`) letters (`[A-z]`) per word and are separated by a
white-space character. In the substitution string (`s""`) we use back-references
in reversed order (`\2` and `\1`) and separate them with a comma (`","`):

```
# random names
names = ["Mary Johnson", "Eve Smith", "Tom Brown"]

replace.(names, r"([A-z]+) ([A-z]+)" => s"\2, \1")
```

```
[
	"Johnson, Mary",
	"Smith, Eve",
	"Brown, Tom"
]
```

Once we got them formatted sorting shouldn't be a problem either:

```
replace.(names, r"([A-z]+) ([A-z]+)" => s"\2, \1") |> sort
```

```
[
	"Brown, Tom",
	"Johnson, Mary",
	"Smith, Eve"
]
```

OK, time for some more complicated names:

```
# random names
names = [
	"Jane Johnson",
	"Mary Jane Doe",
	"Peter Smith",
	"Adam Tom Brown"
]
```

Let's build our regex step by step. We start by matching a middle name (if there
is one).

```
eachmatch.(r" [A-z]+ ", names) .|> getAllMatches
```

```
[
	[],
	[" Jane "],
	[],
	[" Tom "]
]
```

Here we search for a word between two spaces, more specifically: a white-space
character, at least one letter (`[A-z]+`) and a white-space character.

Time to abbreviate the middle name:

```
replace.(names, r" ([A-Z])[a-z]+ " => s" \1. ")
```

```
[
	"Jane Johnson",
	"Mary J. Doe",
	"Peter Smith",
	"Adam T. Brown"
]
```

For that we modified the previous regex. This time we looked for a white-space
character, one capital letter (`[A-Z]`), at least one small letter (`[a-z]+`)
and a white-space character. Out of the whole match (`" ([A-Z])[a-z]+ "`) we
captured (`()`) and remembered only the capital letter, which we used in the
substitution string (`s""`) followed by a literal dot (`\1.`). Therefore, we
replaced the whole match (`" ([A-Z])[a-z]+ "`) by its first capture group that
we memorized and referred back to with (`\1`).

Now, time for the swap:

```
replace.(names, r" ([A-Z])[a-z]+ " => s" \1. ") |>
abbrevNames -> replace.(abbrevNames, r"([A-z .]+) ([A-z]+)" => s"\2, \1")
```

```
[
	"Johnson, Jane",
	"Doe, Mary J.",
	"Smith, Peter",
	"Brown, Adam T."
]
```

Here, instead of being clever and building a one complicated regex, we just
passed the result of one `replace` function as an input to another `replace`
function. The second regex looks for at least one letter, space or literal dot
(`[A-z .]+`, this captures as many consecutive words as it can because of the
greediness) followed by one word (`[A-z]+`, one or more letters). We captured
the words with `()` and swapped them with back-references (`\2` and `\1`), while
putting a comma (`,`) between them.

OK, now for the last step, sorting:

```
replace.(names, r" ([A-Z])[a-z]+ " => s" \1. ") |>
abbrevNames -> replace.(abbrevNames, r"([A-z .]+) ([A-z]+)" => s"\2, \1") |>
sort
```

```
[
	"Brown, Adam T.",
	"Doe, Mary J.",
	"Johnson, Jane",
	"Smith, Peter"
]
```

And we're done.

### Regex Solution 4 {#sec:regex_problem_solution4}

OK, time for a tough challenge. Let's properly format `nums` using only the
regex techniques we learned so far (see @sec:regex_problem_intro) + some
built-in Julia functions. My first try would look something like:

```
nums = [0, 1, 12, 123, 1234, 12345,
	123456, 1234567, 12345678, 123456789]

replace.(string.(nums), r"(\d{3})" => s"\1,")
```

```
# no commas separating elts of vector, to make it more legible
[
	"0"
	"1"
	"12"
	"123,"
	"123,4"
	"123,45"
	"123,456,"
	"123,456,7"
	"123,456,78"
	"123,456,789,"
]
```

Overall, we did a pretty good job. First, we changed the integers (`nums`) into
strings (by using `string` function). Next, we said: while moving left to right
(default direction for a regex engine) match exactly three digits (`\d{3}`) and
remember them (`(...)`). Finally, insert the remembered digits followed by a
comma (`"\1,"`). There is a small problem though. The triplets are matched
starting from left side instead of the right (which we would prefer). Not a
problem, we'll just reverse the string before transformation (putting commas).

```
replace.(reverse.(string.(nums)), r"(\d{3})" => s"\1,")
```

```
# no commas separating elts of vector, to make it more legible
[
	"0"
	"1"
	"21"
	"321,"
	"432,1"
	"543,21"
	"654,321,"
	"765,432,1"
	"876,543,21"
	"987,654,321,"
]
```

OK, the commas are placed every three digits from right (if you consider the
original numbers). Now we would like to remove the stray comma at the end of
some lines (`r",$" => ""`) and reverse the string again (to restore the original
order):

```
replace.(reverse.(string.(nums)), r"(\d{3})" => s"\1,") |>
reversedNums -> replace.(reversedNums, r",$" => "") .|> reverse
```

```
# no commas separating elts of vector, to make it more legible
[
	"0"
	"1"
	"12"
	"123"
	"1,234"
	"12,345"
	"123,456"
	"1,234,567"
	"12,345,678"
	"123,456,789"
]
```

To make it slightly more elegant we can enclose the entire procedure into a
function:

```
function fmtMoney(n::Int)::Str
    @assert n >= 0 "n must be >= 0"
    result::Str = replace(reverse(string(n)), r"(\d{3})" => s"\1,")
    return replace(result, r",$" => "") |> reverse
end
```

And use it for money formatting:

```
fmtMoney.(nums) .* " USD"
```

```
[
	"0 USD",
	"1 USD",
	"12 USD",
	"123 USD",
	"1,234 USD",
	"12,345 USD",
	"123,456 USD",
	"1,234,567 USD",
	"12,345,678 USD",
	"123,456,789 USD"
]
```

The above `fmtMoney` is a five line regex equivalent of the fifteen lines long
`getFormattedMoney` from @sec:compound_interest_problem_q4. Likely, it could be
shortened even more by applying [lookahead
assertions](https://en.wikipedia.org/wiki/Regular_expression#Assertions) (we
didn't use them, since they had not been discussed in @sec:regex_problem_intro).

Now, let's go one step further and try to format also decimals. For that, we'll
split a number into dollars (integers) and cents (two digits after comma,
rounded if necessary).

```
function getDollarsCents(money::Flt)::Tuple{Int, Int}
    @assert money >= 0 "money must be >= 0"
    integralPart::Int = floor(Int, money)
    decimalPart::Flt = money % 1
    return (integralPart, round(Int, decimalPart*100))
end
```

Once we got it, we will use `fmtMoney(n::Int)::Str` to format the dollars to
which we'll append the cents:

```
function fmtMoney(n::Flt)::Str
    @assert n >= 0 "n must be >= 0"
    dollars::Int, cents::Int = getDollarsCents(n)
    result::Str = fmtMoney(dollars)
    return string(result, ".", cents)
end
```

Time to test it out:

```
nums = [0, 0.1, 1, 1.2, 12., 12.34, 123.456,
	1234, 12345, 12345.67, 123456.7, 1234567.89]

fmtMoney.(nums) .* " USD"
```

```
[
	"0.0 USD",
	"0.10 USD",
	"1.0 USD",
	"1.20 USD",
	"12.0 USD",
	"12.34 USD",
	"123.46 USD",
	"1,234.0 USD",
	"12,345.0 USD",
	"12,345.67 USD",
	"123,456.70 USD",
	"1,234,567.89 USD"
]
```

Looks like we finished the job. Regular expressions are worth learning even at a
relatively basic level. Sometimes they can really speed things up or reduce the
amount of code.
