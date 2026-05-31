const Flt = Float64
const Str = String
const Vec = Vector

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

function getProgressBar(perc::Int)::Str
    @assert 0 <= perc <= 100 "perc must be in range [0-100]"
    maxNumChars::Int = 50
    p::Int = round(Int, perc / (100 / maxNumChars))
    return "|" ^ p * "." ^ (maxNumChars-p) * " $perc%"
end

# the terminal must support ANSI escape codes
# https://en.wikipedia.org/wiki/ANSI_escape_code
function clearPrintout()::Nothing
    #"\033[xxxA" - xxx moves cursor up xxx lines
    print("\033[1A")
    # clears from cursor position till end of display
    print("\033[J")
    return nothing
end

function animateProgressBar()::Nothing
    delaySec::Flt = 0.1
    fans::Vec{Str} = ["\\", "-", "/", "-"]
    lenFans::Int = length(fans)
    for p in 0:100
        delaySec = rand(0.1:0.01:0.25)
        println(getProgressBar(p), " ", fans[(p % lenFans) + 1])
        sleep(delaySec) # sleep accepts delay in seconds
        clearPrintout()
    end
    println(getProgressBar(100))
    return nothing
end

function main()::Nothing
    println("Toy program.")
    println("It animates a progress bar.")
    println("Note: your terminal must support ANSI escape codes.\n")

    # y(es) - default choice (also with Enter), anything else: no
    println("Continue with the animation? [Y/n]")
    choice::Str = readline()
    if lowercase(strip(choice)) in ["y", "yes", ""]
        animateProgressBar()
    end

    println("\nThat's all. Goodbye!")

    return nothing
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
