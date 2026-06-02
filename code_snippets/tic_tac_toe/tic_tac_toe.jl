import Random as Rnd

const Str = String
const Vec = Vector

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

const PLAYERS = ["X", "O"]
# LINES[1:3] - rows, LINES[4:6] - columns, LINES[7:8] - diagonals
const LINES = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
    [1, 4, 7],
    [2, 5, 8],
    [3, 6, 9],
    [1, 5, 9],
    [3, 5, 7],
]
const CENTER_FIELD = 5

function getNewGameBoard()::Vec{Str}
    return string.(1:9)
end

# https://en.wikipedia.org/wiki/ANSI_escape_code#Colors
function getGray(s::Str)::Str
    # "\x1b[90m" sets forground color to gray
    # "\x1b[0m" resets forground color to default value
    return "\x1b[90m" * s * "\x1b[0m"
end

function isFree2Take(field::Str)::Bool
    return !(field in PLAYERS)
end

function getRed(s::Union{Char, Str})::Str
    # "\x1b[31m" sets forground color to red
    return "\x1b[31m" * s * "\x1b[0m"
end

function getGreen(c::Union{Char, Str})::Str
    return "\x1b[32m" * c * "\x1b[0m"
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

function isNPlayerMarks(n::Int, v::Vec{Str})::Bool
    @assert 0 <= n "n must be >= 0 "
    for player in PLAYERS
        if count(==(player), v) == n
            return true
        end
    end
    return false
end

function isTriplet(v::Vec{Str})::Bool
    @assert length(v) == 3 "length(v) must be equal 3"
    return isNPlayerMarks(3, v)
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

function clearLines(nLines::Int)::Nothing
    @assert 0 < nLines "nLines must be a positive integer"
    # "\033[xxxA" - xxx moves cursor up xxx LINES
    print("\033[" * string(nLines) * "A")
    # "\033[0J" - clears from cursor position till the end of the screen
    print("\033[0J")
    return nothing
end

function printBoard(board::Vec{Str})::Nothing
    bd::Vec{Str} = colorFieldNumbers(board)
    bd = colorFirstTriplet(bd)
    for row in LINES[1:3]
        println(" ", join(bd[row], " | "))
        println("---+---+---")
    end
    clearLines(1)
    return nothing
end

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
    input::Str = getUserInput("Enter your move [1-9]: ")
    while !isMoveLegal(input, gameBoard)
        clearLines(1)
        input = getUserInput("Illegal move. Try again. Enter your move [1-9]: ")
    end
    return parse(Int, input)
end

function getFreeFields(board::Vec{Str})::Vec{Int}
    return parse.(Int, filter(isFree2Take, board))
end

function isDoublet(v::Vec{Str})::Bool
    @assert length(v) == 3 "length(v) must be equal 3"
    freeFieldsOK::Bool = length(getFreeFields(v)) == 1
    return isNPlayerMarks(2, v) && freeFieldsOK
end

function getIndToBlockOrWin(board::Vec{Str})::Int
    move::Int = 0
    for line in LINES[Rnd.randperm(length(LINES))]
        if isDoublet(board[line])
            move = getFreeFields(board[line]) |> first
            break
        end
    end
    return move
end

function getComputerMove(board::Vec{Str})::Int
    move::Int = getIndToBlockOrWin(board)
    move = (move != 0) ? move :
        isFree2Take(board[CENTER_FIELD]) ? CENTER_FIELD :
        Rnd.rand(getFreeFields(board))
    println("Computer plays: ", move)
    return move
end

function makeMove!(move::Int, player::Str, board::Vec{Str})::Nothing
    @assert move in eachindex(board) "move must be in range [1-9]"
    @assert player in PLAYERS "player must be X or O"
    if isFree2Take(board[move])
        board[move] = player
    end
    return nothing
end

function playMove!(player::Str, board::Vec{Str})::Nothing
    @assert player in PLAYERS "player must be X or O"
    printBoard(board)
    move::Int = (player == "X") ? getUserMove(board) : getComputerMove(board)
    makeMove!(move, player, board)
    clearLines(6)
    printBoard(board)
    return nothing
end

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

function displayGameOverScreen(player::Str, board::Vec{Str})::Nothing
    @assert player in PLAYERS "player must be X or O"
    printBoard(board)
    print("Game Over. ")
    isGameWon(board) ?
        println(player == "X" ? "You" : "Computer", " won.") :
        println("Draw.")
    return nothing
end

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

function isAnsiColorSupport()::Bool
    try
        nColors::Int = parse(Int, read(`tput colors`, String))
        return nColors >= 8
    catch
        return false
    end
end

function areRequirementsMet(verbose::Bool=true)::Bool
    requirementsMet::Bool = true
    verbose ? println("Checking requirements...") : nothing
    if !isAnsiColorSupport()
        requirementsMet &= false
        verbose ?
            println(getRed("No suport for ANSI colors found.")) :
            nothing
    end
    (requirementsMet && verbose) ?
        println(getGreen("Requirements seem to be met.\n")) :
        nothing
    return requirementsMet
end

function main()::Nothing
    println("\nThis is a toy program to play a tic-tac-toe game.")
    println("Note: your terminal must support ANSI escape codes.\n")

    if !areRequirementsMet()
        println("Requirements not met!")
        println("\nLeaving the program. Goodbye!")
        return nothing
    end

    # y(es) - default choice (also with Enter), anything else: no
    println("Continue with the game? [Y/n]")
    choice::Str = readline()
    if lowercase(strip(choice)) in ["y", "yes", ""]
        playGame()
    end

    println("\nThat's all. Goodbye!")

    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
