import Random as Rnd
import Base: +

const Flt = Float64
const Vec = Vector

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

@enum Player naive gullible unforgiving paybacker unfriendly abusive egoist
@enum Choice cooperate=0 betray=1

function +(c1::Choice, c2::Choice)::Int
    return Int(c1) + Int(c2)
end

function +(n::Int, c::Choice)::Int
    return n + Int(c)
end

function getMove(p::Player, opponentMoves::Vec{Choice})::Choice
    prob::Flt = Rnd.rand() # random float in range [0.0-1.0)
    if p == naive
        return cooperate
    elseif p == unforgiving
        return sum(opponentMoves, init=0) > 3 ? betray : cooperate
    elseif p == gullible
        return prob <= 0.9 ? cooperate : betray
    elseif p == paybacker
        return isempty(opponentMoves) ? cooperate : opponentMoves[end]
    elseif p == unfriendly
        return prob <= 0.6 ? betray : cooperate
    elseif p == abusive
        return prob <= 0.8 ? betray : cooperate
    else # egoist player
        return betray
    end
end

function getPts(c1::Choice, c2::Choice)::Tuple{Int, Int}
    if c1 == c2 == cooperate
        return (2, 2)
    elseif c1 > c2
        return (3, -2)
    elseif c1 < c2
        return (-2, 3)
    else # both betray
        return (-1, -1)
    end
end

function playRoundsGetPts(p1::Player, p2::Player)::Tuple{Int, Int}
    pts1::Int, pts2::Int = 0, 0 # total pts
    mvs1::Vec{Choice}, mvs2::Vec{Choice} = [], [] # all moves
    mv1::Choice, mv2::Choice = cooperate, cooperate # move per round
    pt1::Int, pt2::Int = 0, 0 # pts per round
    nRounds::Int = Rnd.rand(50:300)
    for _ in 1:nRounds
        mv1, mv2 = getMove(p1, mvs2), getMove(p2, mvs1)
        pt1, pt2 = getPts(mv1, mv2)
        push!(mvs1, mv1)
        push!(mvs2, mv2)
        pts1 += pt1
        pts2 += pt2
    end
    return (pts1, pts2)
end

function playGame(players::Vec{Player})::Dict{Player, Int}
    playersPts::Dict{Player, Int} = Dict(p => 0 for p in players)
    alreadyPlayed::Dict{Player, Bool} = Dict()
    for player1 in players, player2 in players
        if player1 == player2 || haskey(alreadyPlayed, player2)
            continue
        end
        pts1, pts2 = playRoundsGetPts(player1, player2)
        playersPts[player1] += pts1
        playersPts[player2] += pts2
        alreadyPlayed[player1] = true
    end
    return playersPts
end

# Test1
Rnd.seed!(303)
playGame([naive, unforgiving, paybacker, unfriendly, abusive, egoist])
# 1 - unforgiving, 2 - paybacker, 3 - egoist
# good/bad = 2/1

# Test2
Rnd.seed!(310)
playGame([naive, unforgiving, paybacker, unfriendly, abusive, egoist])
# 1 - unforgiving, 2 - paybacker, 3 - naive
# good/bad = 3/0

# Test3
Rnd.seed!(401)
playGame([naive, unforgiving, paybacker, unfriendly, abusive, egoist])
# 1 - unforgiving, 2 - paybacker, 3 - egoist
# good/bad = 2/1

###
# replace unforgiving with gullible (prob of cooperate ~90%)
# and observe how the results change
###

# Test4
Rnd.seed!(303)
playGame([naive, gullible, paybacker, unfriendly, abusive, egoist])
# previous results:
# 1 - unforgiving, 2 - paybacker, 3 - egoist (good/bad = 2/1)
# current results:
# 1 - unfriendly, 2 - egoist, 3 - paybacker (good/bad = 1/2)

# Test5
Rnd.seed!(310)
playGame([naive, gullible, paybacker, unfriendly, abusive, egoist])
# previous results:
# 1 - unforgiving, 2 - paybacker, 3 - naive (good/bad = 3/0)
# current results:
# 1 - abusive, 2 - unfriendly, 3 - egoist (good/bad = 0/3)

# Test6
Rnd.seed!(401)
playGame([naive, gullible, paybacker, unfriendly, abusive, egoist])
# previous results:
# 1 - unforgiving, 2 - paybacker, 3 - egoist (good/bad = 2/1)
# current results:
# 1 - unfriendly, 2 - egoist, 3 - paybacker (good/bad = 1/2)
