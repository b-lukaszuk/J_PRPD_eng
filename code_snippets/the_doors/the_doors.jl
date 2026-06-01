import DataFrames as Dfs
import Random as Rnd

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

const Flt = Float64
const Vec = Vector

###############################################################################
#                                  solution 1                                 #
###############################################################################
df = Dfs.DataFrame(Dict("Door" => 1:3))
df.prior = repeat([1/3], 3)
df

df.likelihood = [1/2, 1, 0]
df

function bayesUpdate!(df::Dfs.DataFrame)::Nothing
    unnorm = df.prior .* df.likelihood
    df.posterior = unnorm ./ sum(unnorm)
    return nothing
end

bayesUpdate!(df)
df

###############################################################################
#                                  solution 2                                 #
###############################################################################
mutable struct Door
    isCar::Bool
    isChosen::Bool
    isOpen::Bool
end


# get n random doors, 1 with a car, 1 chosen by the trader
function getNRandDoors(n::Int)::Vec{Door}
    @assert 2 < n < 10 "n must be in range [3-9]"
    doors::Vec{Door} = [Door(false, false, false) for _ in 1:n]
    doors[Rnd.rand(1:n)].isCar = true
    doors[Rnd.rand(1:n)].isChosen = true
    return doors
end

# open random non-chosen, non-car door
function openEligibleDoor!(doors::Vec{Door})::Nothing
    @assert 2 < length(doors) < 10 "length(doors) must be in range [3-9]"
    indsEligible::Vec{Int} = findall(d -> !d.isCar && !d.isChosen, doors)
    ind2Open::Int = indsEligible[Rnd.rand(1:length(indsEligible))]
    doors[ind2Open].isOpen = true
    return nothing
end

# swap to random non-chosen, non-open door
function swapChoice!(doors::Vec{Door})::Nothing
    @assert 2 < length(doors) < 10 "length(doors) must be in range [3-9]"
    indCurChosen::Int = findfirst(d -> d.isChosen, doors)
    inds2Choose::Vec{Int} = findall(d -> !d.isChosen && !d.isOpen, doors)
    ind2Choose::Int = inds2Choose[Rnd.rand(1:length(inds2Choose))]
    doors[indCurChosen].isChosen = false
    doors[ind2Choose].isChosen = true
    return nothing
end

function didTraderWin(doors::Vec{Door})::Bool
    indWinner::Union{Nothing, Int} = findfirst(
        d -> d.isChosen && d.isCar, doors)
    # or: return !isnothing(indWinner)
    return isnothing(indWinner) ? false : true
end

function getResultOfDoorsGame(nDooors::Int, shouldSwap::Bool=false)::Bool
    doors::Vec{Door} = getNRandDoors(nDooors)
    openEligibleDoor!(doors)
    if shouldSwap
        swapChoice!(doors)
    end
    return didTraderWin(doors)
end

# treats: true as 1, false as 0
function getAvg(successes::Vec{Bool})::Flt
    return sum(successes) / length(successes)
end

function getProbOfWinningDoorsGame(nDoors::Int, shouldSwap::Bool=false,
                                   nSimul::Int=10_000)::Flt
    @assert 1e3 <= nSimul <= 1e5 "nSimul must be in range [1e3 - 1e5]"
    return [getResultOfDoorsGame(nDoors, shouldSwap) for _ in 1:nSimul] |> getAvg
end

Rnd.seed!(1492)
getProbOfWinningDoorsGame(3, false)
getProbOfWinningDoorsGame(3, true)

###############################################################################
#                                  solution 3                                 #
###############################################################################
function getAllDoorSets(nDoorsPerSet::Int)::Vec{Vec{Door}}
    @assert 2 < nDoorsPerSet < 10 "nDoorsPerSet must be in range [3-9]"
    allDoorSets::Vec{Vec{Door}} = []
    subset::Vec{Door} = Door[]
    for indCar in 1:nDoorsPerSet, indChosen in 1:nDoorsPerSet
        subset = [Door(false, false, false) for _ in 1:nDoorsPerSet]
        subset[indCar].isCar = true
        subset[indChosen].isChosen = true
        push!(allDoorSets, subset)
    end
    return allDoorSets
end

# open random non-chosen, non-car door
function openEligibleDoor!(doors::Vec{Door})::Vec{Door}
    @assert 2 < length(doors) < 10 "length(doors) must be in range [3-9]"
    indsEligible::Vec{Int} = findall(d -> !d.isCar && !d.isChosen, doors)
    ind2Open::Int = indsEligible[Rnd.rand(1:length(indsEligible))]
    doors[ind2Open].isOpen = true
    return doors # instead of: return nothing
end

# swap to random non-chosen, non-open door
function swapChoice!(doors::Vec{Door})::Vec{Door}
    @assert 2 < length(doors) < 10 "length(doors) must be in range [3-9]"
    indCurChosen::Int = findfirst(d -> d.isChosen, doors)
    inds2Choose::Vec{Int} = findall(d -> !d.isChosen && !d.isOpen, doors)
    ind2Choose::Int = inds2Choose[Rnd.rand(1:length(inds2Choose))]
    doors[indCurChosen].isChosen = false
    doors[ind2Choose].isChosen = true
    return doors # instead of: return nothing
end

map(didTraderWin ∘ openEligibleDoor!, getAllDoorSets(3)) |> getAvg,
map(didTraderWin ∘ swapChoice! ∘ openEligibleDoor!,
    getAllDoorSets(3)) |> getAvg
