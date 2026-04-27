# Touch Typing {#sec:touch_typing}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/touch_typing)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:touch_typing_problem}

In this exercise your job is to write a
[terminal](https://en.wikipedia.org/wiki/Terminal_emulator) based application,
similar to the one presented in the GIF below, that measures your (touch) typing
speed.

![A terminal based application that measures typing speed (animation works only in an HTML document).](./images/touchTyping.gif){#fig:touchTyping}

Your program should:

- mark the characters (in)correctly typed
- allow to delete the (incorrectly) typed characters
- display some basic summary of the speed (like WPM - words per minute)

To make it easier, you may assume it to always operate on a short line of text
(let's say 50 characters long) composed only of the characters from the standard
Latin alphabet encoded by [ASCII](https://en.wikipedia.org/wiki/ASCII).

## Solution {#sec:touch_typing_solution}

Let's approach the problem one step at a time. First, a formatting function
`getColoredTxt`. The function will colorize the letters based on the correctness
of our input. To that end we will reuse some of the code (see `getRed` and
`getGreen` below) from the previous chapter (see @sec:tic_tac_toe_solution).

```
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
function getRed(c::Char)::Str
    return "\x1b[31m" * s * "\x1b[0m"
end

function getGreen(c::Char)::Str
    return "\x1b[32m" * s * "\x1b[0m"
end

function getColoredTxt(typedTxt::Str, referenceTxt::Str)::Str
    result::Str = ""
    for i in eachindex(referenceTxt)
        if i > length(typedTxt)
            result *= referenceTxt[i]
        elseif typedTxt[i] == referenceTxt[i]
            result *= getGreen(referenceTxt[i])
        else
            result *= getRed(referenceTxt[i])
        end
    end
    return result
end
```

> **_Note:_** In this chapter we rely on the assumption that we operate on a
> text composed of standard ASCII charset. Be aware that in the case of other
> charsets the indexing may not work as intended (see [the
> docs](https://docs.julialang.org/en/v1/manual/strings/#Unicode-and-UTF-8)).

The code is rather simple, we traverse the `referenceTxt`, i.e. the text we are
suppose to type, with a `for` loop and indexing (`i`). If the text we already
typed (`typedTxt`) is shorter than the current index (`i > length(typedTxt)`) we
just append the character of the reference text to the `result` without coloring
(`result *= referenceTxt[i]`). Otherwise we color the character of our
`referenceTxt[i]` green (`getGreen`) in the case of a match
(`typedTxt[i] == referenceTxt[i]`) or we color it red (`getRed`)
otherwise. Finally, we `return` the colored text (`result`) for printout.

Now, in order to play our touch typing game we need a way to read a character or
characters from the
[terminal](https://en.wikipedia.org/wiki/Terminal_emulator). This could be done
with [read](https://docs.julialang.org/en/v1/base/io-network/#Base.read) or with
`readline` that we met in @sec:tic_tac_toe_solution. The problem is that by
default, those are blocking functions (you need to press Enter for the
`Char`/`String` to be read into your program). It turns out that an immediate,
non-blocking readout in Julia isn't trivial to get. One option suggested by the
[Rosetta
Code](https://rosettacode.org/wiki/Keyboard_input/Flush_the_keyboard_buffer#Julia)
website is to use an external library (the Gtk.jl presented in the link above
seems to be no longer maintained). Other possibility would be to do this in a
programming language better adjusted for such low level tasks, like C, and
execute it from Julia (similarly to the suggestions found in [this
video](https://www.youtube.com/watch?v=obCMGkQ8Y8g)). However, in order to keep
the solution minimal I will rely on `stty`, a terminal command found in
UNIX(like) systems. If you don't have it on your computer you need to find some
other way (or just skip this task).

> **_Note:_** Type `man stty` (and press Enter) into your terminal to check if
> you have the program installed on your system (`q` - closes the man page).

OK, let's play the game.

```
# more info on stty, type in the terminal: man stty
# display current stty settings with: stty -a (or: stty --all)
function playTypingGame(text2beTyped::Str)::Str
    c::Char = ' '
    typedTxt::Str = ""
    cursorCol::Int = 1
    run(`stty raw -echo`) # raw mode - reads single character immediately
    while length(text2beTyped) > length(typedTxt)
        print("\r", getColoredTxt(typedTxt, text2beTyped))
        print("\x1b[", cursorCol, "G") # mv curs to cursorCol
        c = read(stdin, Char) # read a character without Enter
        typedTxt *= c
        cursorCol = length(typedTxt) + 1
    end
    println("\r", getColoredTxt(typedTxt, text2beTyped))
    run(`stty cooked echo`) # reset to default behavior
    return typedTxt
end
```

First, we declare and initialize a couple of variables that we will use later
on: `c` to hold the character typed by the user, `typedTxt` to contain
everything that the player typed and `cursorCol` which is a cursor position over
a letter to be typed. Next, we execute a proper terminal command with
[run](https://docs.julialang.org/en/v1/base/base/#Base.run) (notice the
backticks). Now, for as long (`while`) as we haven't typed the whole
`text2beTyped` (`length(text2beTyped) > length(typedTxt)`) we print the colored
text (`\r` moves the cursor to the beginning of the line). Of course, we
remember to set the cursor in the appropriate column (`"\x1b[", cursorCol,
"G"`). Next we `read` a character typed by the player
(`stdin` means [standard input](https://en.wikipedia.org/wiki/Standard_streams),
it is a variable defined by
[Base](https://docs.julialang.org/en/v1/base/base/#Base)). Afterwords, we append
the character (`c`) to the `typedTxt` and move the cursor by one column. Once we
finish, we do some cleanup. We reprint the whole typed text and reset the
terminal to its default values with `run`. We return `typedTxt` for further
usage (by a summary function that will be defined soon).

The above is a reasonable approach, but there is a small problem with our
`playTypingGame`. The raw mode that we use will turn off special treatments of
key-presses that we are accustomed to. For instance, currently there is no way
to delete a character, nor terminate a program early with customary (Ctrl-C). I
order to get this behavior we need to either turn off the raw mode or fix the
problem ourselves.

```
function isDelete(c::Char)::Bool
    return c == '\x08' || c == '\x7F' # bacspace or delete
end

function isAbort(c::Char)::Bool
    return c == '\x03' || c == '\x04' # Ctrl-C or Ctrl-D
end

# more info on stty, type in the terminal: man stty
# display current stty settings with: stty -a (or: stty --all)
function playTypingGame(text2beTyped::Str)::Str
    c::Char = ' '
    typedTxt::Str = ""
    cursorCol::Int = 1
    run(`stty raw -echo`) # raw mode - reads single character immediately
    while length(text2beTyped) > length(typedTxt)
        print("\r", getColoredTxt(typedTxt, text2beTyped))
        print("\x1b[", cursorCol, "G") # mv curs to cursorCol
        c = read(stdin, Char) # read a character without Enter
        if isDelete(c)
            typedTxt = typedTxt[1:(end-1)]
        elseif isAbort(c)
            break
        elseif isascii(c)
            typedTxt *= c
        else # do noting if user types e.g. ś ć or other strange chars
            nothing
        end
        cursorCol = length(typedTxt) + 1
    end
    println("\r", getColoredTxt(typedTxt, text2beTyped))
    run(`stty cooked echo`) # reset to default behavior
    return typedTxt
end
```

Much better. we just check for the hexadecimal (`\x`) [ASCII
code](https://pl.wikipedia.org/wiki/ASCII) for the specific characters. When a
delete key is pressed we remove the last character from the typed text
(`typedTxt[1:(end-1)]`). When an abort signal is send we just `break` the loop
and leave early.

Now, we add the summary statistics.

```
function getAccuracy(typedTxt::Str, text2beTyped::Str)::Flt
    len1::Int = length(typedTxt)
    len2::Int = length(text2beTyped)
    @assert len1 <= len2 "len1 must be <= len2"
    correctlyTyped::Vec{Bool} = Vec{Bool}(undef, len1)
    for i in eachindex(correctlyTyped)
        correctlyTyped[i] = typedTxt[i] == text2beTyped[i]
    end
    return sum(correctlyTyped) / length(correctlyTyped)
end

function printSummary(typedTxt::Str, text2beTyped::Str,
                      elapsedTimeSec::Flt)::Nothing
    wordLen::Int = 5 # avg. word length in English
    secsPerMin::Int = 60
    len1::Int = length(typedTxt)
    len2::Int = length(text2beTyped)
    cpm::Flt = len1 / elapsedTimeSec * secsPerMin
    wpm::Flt = cpm / wordLen
    acc::Flt = getAccuracy(typedTxt, text2beTyped)
    println("\n---Summary---")
    println("Elapsed time: ", round(elapsedTimeSec, digits=2), " seconds")
    println("Typed characters: $len1/$len2")
    println("Characters per minute: ", round(cpm, digits=1))
    println("Words per minute: ", round(wpm, digits=1))
    println("Accuracy: ", round(acc * 100, digits=2), "%")
    return nothing
end
```

You can choose a different set of statistics, but I picked accuracy (% of
characters that were typed correctly), number of characters per minute (`cpm`)
and number of words per minute `wpm`.

As before (see @sec:tic_tac_toe_solution) we finish with the main function.

```
function main()::Nothing

    println("Hello. This is a toy program for touch typing.")
    println("It should work well on terminals that: ")
    println("- support ANSI escape codes,")
    println("- got stty.\n")

    println("Press Enter (or any key and Enter) and start typing.")
    println("Press q and Enter to quit now.")
    choice::Str = readline()

    if lowercase(strip(choice)) != "q"
        txt2type::Str = "Julia is awesome. Try it out in 2025 and beyond!"
        timeStart::Flt = time()
        typedTxt::Str = playTypingGame(txt2type)
        timeEnd::Flt = time()
        elapsedTimeSeconds::Flt = timeEnd - timeStart
        printSummary(typedTxt, txt2type, elapsedTimeSeconds)
    end

    println("\nThat's all. Goodbye!")

    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
```

And voila, the task was completed in like a hundred lines of code or so. You may
now open your terminal, type: `julia touch_typing.jl` and test your typing
speed.

If you still haven't had enough then feel free to extend the program so that it
can also handle a bit longer, multi-line texts. Alternatively, you may examine
such a program in the [code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/touch_typing).
