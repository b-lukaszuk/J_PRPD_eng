# Tic-Tac-Toe {#sec:tic_tac_toe}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/tic_tac_toe)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:tic_tac_toe_problem}

Write a program that will enable you to play a simple
[tic-tac-toe](https://en.wikipedia.org/wiki/Tic-tac-toe) game. It may look like
the one in @fig:ttt.

![A simple terminal based tic tac toe game (animation works only in an HTML document).](./images/ttt.gif){#fig:ttt}

In case you wanted to use the same colors as in the gif above, you may find the
[ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code#Colors)
useful.

## Solution {#sec:tic_tac_toe_solution}

The first decision we must make is the internal representation of our game
board. Two candidate data types come to mind right away, a vector or a
matrix. Here, I'll go with the first option.

```jl
s = """
function getNewGameBoard()::Vec{Str}
    return string.(1:9)
end
"""
sc(s)
```

Next, we'll define a few constants that will be helpful later on.

```jl
s = """
PLAYERS = ["X", "O"]
# LINES[1:3] - rows, LINES[4:6] - columns, LINES[7:8] - diagonals
LINES = [
	[1, 2, 3],
	[4, 5, 6],
	[7, 8, 9],
	[1, 4, 7],
	[2, 5, 8],
	[3, 6, 9],
	[1, 5, 9],
	[3, 5, 7]
]
"""
replace(sc(s), r"\bPLAYERS" => "const PLAYERS", r"\bLINES " => "const LINES")
```

> Note. Using `const` with mutable containers like vectors or dictionaries
> allows to change their contents later on, e.g., with `push!`. So the `const`
> used here is more like a convention, a signal that we do not plan to change
> the containers in the future. If we really wanted an immutable container then
> we should consider a(n) (immutable) tuple. Anyway, some programming languages
> suggest that `const` names should be declared using all uppercase characters
> to make them stand out. Here, I follow this convention.

The two are: `PLAYERS`, a vector with marks used by each of the players (`"X"` -
human, `"O"` - computer) and the coordinates of `LINES` in our game board that
we need to check to see if a player won the game. You could probably be more
clever and use
[enums](https://docs.julialang.org/en/v1/base/base/#Base.Enums.Enum) for the
players and list comprehensions for our lines (e.g.,
`[collect(i:(i+2)) for i in [1, 4, 7]]` to get the rows),
but for such a simple case it might be overkill.

OK, time to format the board.

```jl
s = """
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
function getGray(s::Str)::Str
    # "\\x1b[90m" sets forground color to gray
    # "\\x1b[0m" resets forground color to default value
    return "\\x1b[90m" * s * "\\x1b[0m"
end

function isFree2Take(field::Str)::Bool
    return !(field in PLAYERS)
end

function colorFieldNumbers(board::Vec{Str})::Vec{Str}
    result::Vec{Str} = copy(board)
    for i in eachindex(board)
        if isFree2Take(board[i])
            result[i] = getGray(board[i])
        end
    end
    return result
end
"""
sc(s)
```

We begin with the definition of `getGray` that will change the
font color of the selected symbols from our game board. This should look nice on
a standard, dark terminal display. Still, feel free to adjust the color to your
needs (although if you use a terminal with a white background you may rather
stop and get some help). Anyway, a field not taken by one of the players
(`isFree2Take`) will be colored by `colorFieldNumbers`.

Personally, I would also opt to add the function for the triplets detection
(`isTriplet`), which we will use to color them (first one we find based on
`LINES`) with `colorFirstTriplet`. This should allow us for easier visual
determination when the game is over (later on we will also use it in
`isGameWon`).

```jl
s = """
# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
function getRed(s::Str)::Str
    # "\\x1b[31m" sets forground color to red
    # "\\x1b[0m" resets forground color to default value
    return "\\x1b[31m" * s * "\\x1b[0m"
end

function isTriplet(v::Vec{Str})::Bool
    @assert length(v) == 3 "length(v) must be equal 3"
    return join(v) == "XXX" || join(v) == "OOO"
end

function colorFirstTriplet(board::Vec{Str})::Vec{Str}
    result::Vec{Str} = copy(board)
    for line in LINES
        if isTriplet(board[line])
            result[line] = getRed.(result[line])
            return result
        end
    end
    return result
end
"""
sc(s)
```

Notice, that neither `colorFieldNumbers`, nor `colorFirstTriplet` modify the
original game board, instead they produce a copy of it which is returned as a
result (since the game board is a short vector there shouldn't be any serious
performance issues).

Now, we are ready to print.

```jl
s = """
# https://en.wikipedia.org/wiki/ANSI_escape_code
function clearLines(nLines::Int)::Nothing
    @assert 0 < nLines "nLines must be a positive integer"
    # "\\033[xxxA" - xxx moves cursor up xxx LINES
    print("\\033[", nLines, "A")
    # "\\033[0J" - clears from cursor position till the end of the screen
    print("\\033[0J")
	return nothing
end

function printBoard(board::Vec{Str})::Nothing
    bd::Vec{Str} = colorFieldNumbers(board)
    bd = colorFirstTriplet(bd)
    for row in LINES[1:3] # first 3 LINES are for rows
        println(" ", join(bd[row], " | "))
        println("---+---+---")
    end
    clearLines(1)
    return nothing
end
"""
sc(s)
```

First, we declare `clearLines`, it will help us to tidy the printout (e.g.,
while playing the game we will have to redraw the game board a couple of times).
Next, we proceed with `printBoard`. We color the board with the previously
defined functions and move row by row (`LINES[1:3]` contains the indices for
the three rows). We `join` the contents of a row together
(we glue them with `" | "`) and print it (`println`).
We follow it by a row separator (`println("---+---+---")`). Once we're finished
we remove the last row separator with `clearLines(1)` (we do not want it, but it
was printed because we were too lazy to add an if statement in our for loop).

So far, so good, time to handle a human player's (aka user's) move.

```jl
s = """
function getUserInput(prompt::Str)::Str
    print(prompt)
    input::Str = readline()
    return strip(input)
end

function isMoveLegal(move::Str, board::Vec{Str})::Bool
    num::Int = 0
    try
        num = parse(Int, move)
    catch
        return false
    end
    return (num in eachindex(board)) && isFree2Take(board[num])
end

function getUserMove(gameBoard::Vec{Str})::Int
    input::Str = getUserInput("Enter your move: ")
    while !isMoveLegal(input, gameBoard)
        clearLines(1)
        input = getUserInput("Illegal move. Try again. Enter your move: ")
    end
    return parse(Int, input)
end
"""
sc(s)
```

> Note. Using `while` loop always carries a risk of it being infinite, that's
> why it is worth to know that you can always press
> [Ctrl+C](https://en.wikipedia.org/wiki/Control-C) that should terminate the
> program execution.

We begin with `getUserInput` a function that takes the `prompt` (its argument,
it tells the user what to do), prints it, and accepts the user's input
(`readline`) that is returned as a result (after `strip`ing it from
space/tab/new line characters that may be on the edges).

Next, we make sure that the move made by the user is legal (`isMoveLegal`),
i.e. it can be correctly converted to an integer (`parse(Int, move)`), it is in
the acceptable range (`num in eachindex(board)`) and is the field free to place
the player's mark (`isFree2Take(board[num])`). Notice, the use of `try` and
`catch` construct. First we `try` to make an integer out of the string obtained
from the user (`parse(Int, move)`). This may fail (e.g., because we got the
letter `"a"` instead of the number `"2"`). Such a failure, will result in an
error that would normally terminate the program execution. We don't want that to
happen, so we `catch` a possible error and instead of terminating the program,
we just `return false`. If the `try` succeeds, we skip the `catch` part and go
straight to the next statement after the `try`-`catch` block
(`return (num in eachindex(board)) && isFree2Take(board[num])`) that we already
discussed.

Finally, we declare `getUserMove`, a function that asks the user for a move and
is quite persistent about it. If the user gives a correct move the first time
(`input::Str = getUserInput("Enter your move: ")`) then the while loop condition
(`!isMoveLegal(input, gameBoard)`) is false and the loop isn't executed at all
(we move to the return statement). However, if the user plays tricks on us and
wants to smuggle an illegal move (or maybe they just did it absent-mindedly)
then the condition (`!isMoveLegal(input, gameBoard)`) is true and `while` it is
we nag the user for a correct move
(`"Illegal move. Try again. Enter your move: "`).

OK, and how about a computer move.

```jl
s = """
function getComputerMove(board::Vec{Str})::Int
    move::Int = 0
    for i in eachindex(board)
        if isFree2Take(board[i])
            move = i
            break
        end
    end
    println("Computer plays: ", move)
    return move
end
"""
sc(s)
```

We start small, `getComputerMove` will simply walk through the board and return
an index (`i`) of a first empty, i.e., not taken by a player
(`isFree2Take(board[i])`) field. If all the fields are taken it will return `0`
(in reality this will never happen as we will see in `playGame` later on). Since
`getUserMove` prints one line of a screen output, then so does `getComputerMove`
(`println("Computer plays: ", move)`) for compatibility.

Time to actually make a move that we obtained for a player.

```jl
s = """
function makeMove!(move::Int, player::Str, board::Vec{Str})::Nothing
    @assert move in eachindex(board) "move must be in range [1-9]"
    @assert player in PLAYERS "player must be X or O"
    if isFree2Take(board[move])
        board[move] = player
    end
    return nothing
end
"""
sc(s)
```

For that we just take the `move`, a `player` for whom we place the mark, and the
game `board` that we will modify. If a given field isn't taken (or to put it
differently, it's free to take, hence `if isFree2Take(board[move])`) we just put
the mark for a player there (`board[move] = player`).

Time to write `playMove`, a function that will handle a player, their move and
its display on the screen.

```jl
s = """
function playMove!(player::Str, board::Vec{Str})::Nothing
    @assert player in PLAYERS "player must be X or O"
    printBoard(board)
    move::Int = (player=="X") ? getUserMove(board) : getComputerMove(board)
    makeMove!(move, player, board)
    clearLines(6)
    printBoard(board)
    return nothing
end
"""
sc(s)
```

We begin by displaying the board (`printBoard`) and obtaining a `move` for a
player (`(player == "X") ? getUserMove(board) : getComputerMove(board)`). Once
we got the move, we place the correct marker on the board (with `makeMove!`) and
re-draw the board (`clearLines` and `printBoard`).

Now, we are almost ready to actually play a game. Almost, because we need a few
more helper functions. First, we must figure out when the game is over and
why. This can be simply achieved with the following snippet.

```jl
s = """
function isGameWon(board::Vec{Str})::Bool
    for line in LINES
        if isTriplet(board[line])
            return true
        end
    end
    return false
end

function isNoMoreMoves(board::Vec{Str})::Bool
    for i in eachindex(board)
        if isFree2Take(board[i])
            return false
        end
    end
    return true
end

function isGameOver(board::Vec{Str})::Bool
    return isGameWon(board) || isNoMoreMoves(board)
end
"""
sc(s)
```

Once the game is over we display an appropriate info.

```jl
s = """
function displayGameOverScreen(player::Str, board::Vec{Str})::Nothing
    @assert player in PLAYERS "player must be X or O"
    printBoard(board)
    print("Game Over. ")
    isGameWon(board) ?
        println(player == "X" ? "You" : "Computer", " won.") :
        println("Draw.")
    return nothing
end
"""
sc(s)
```

And finally, we're ready to play the game.

```jl
s = """
function togglePlayer(player::Str)::Str
    @assert player in PLAYERS "player must be X or O"
    return player == "X" ? "O" : "X"
end

function playGame()::Nothing
    board::Vec{Str} = getNewGameBoard()
    player::Str = "O"
    while !isGameOver(board)
        player = togglePlayer(player)
        playMove!(player, board)
        clearLines(5)
    end
    displayGameOverScreen(player, board)
    return nothing
end
"""
sc(s)
```

Inside `playGame` we initialize `board` and the `player` on a move. Next, while
the game isn't over (`while !isGameOver(board)`), we toggle the player
(`togglePlayer(player)`), `playMove` and clear the display (`clearLines(5)`)
before another move. When the game is finished we just `displayGameOverScreen`.
And voila. You can `playGame`. Test it, e.g., with the following sequence of
moves: 2, 3, 7, 6, 9 - you win; 2, 3, 6, 8 - computer wins; 7, 2, 4, 6, 9 -
draw.

There are a couple of things to improve on (if you want to). For instance, you
could add a `sleep` statement into `getComputerMove` so that the user got time
to read the message with move declaration (`println("Computer plays: ", move)`).
Moreover, as for now the algorithm generating move in `getComputerMove` is great
for testing, but gets boring pretty quickly, feel free to change it (or try to
beat a slightly more challenging algorithm found in [the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/tic_tac_toe)).

Lastly, like in @sec:progress_bar_solution you could also add the functionality
to run the game from a terminal (with `julia tic_tac_toe.jl`).

```jl
s = """
function main()::Nothing
    println("This is a toy program to play a tic-tac-toe game.")
    println("Note: your terminal must support ANSI escape codes.\\n")

    # y(es) - default choice (also with Enter), anything else: no
    println("Continue with the game? [Y/n]")
    choice::Str = readline()
    if lowercase(strip(choice)) in ["y", "yes", ""]
        playGame()
    end

    println("\\nThat's all. Goodbye!")

    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
"""
sc(s)
```

That's it. Have fun playing the game.
