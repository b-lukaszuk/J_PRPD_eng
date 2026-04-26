import Random as Rnd

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

const Flt = Float64
const Str = String
const Vec = Vector

## Regex Intro
function getTxtFromFile(filePath::Str)::Str
    fileTxt::Str = ""
    try
        fileTxt = open(filePath) do file
            read(file, Str)
        end
    catch
        fileTxt = "Can't read '$filePath'. Make sure it exists."
    end
    return fileTxt
end

txt = getTxtFromFile("./loremJohnSmith.txt");
println(txt)

function getAllMatches(rmi::Base.RegexMatchIterator)::Vec{Str}
    return [regMatch.match for regMatch in rmi]
end

getAllMatches(eachmatch(r"John Smith", txt))

# in Julia strings are immutable
# to make changes permament write it to `txt` and/or to a file
txt = replace(txt, r"John Smith" => "John S");
eachmatch(r"John Smith", txt) |> getAllMatches
println(txt)

### Example 1
txt = getTxtFromFile("./loremDates.txt");
println(txt)

eachmatch(r"[0-9][0-9][0-9][0-9]", txt) |> getAllMatches
eachmatch(r"[0-9]{4}", txt) |> getAllMatches
eachmatch(r"\d{4}", txt) |> getAllMatches

### Example 2
txt = getTxtFromFile("./loremDollarsDates.txt");
println(txt)

eachmatch(r"\d.+\d", txt) |> getAllMatches
eachmatch(r"\d.+?\d", txt) |> getAllMatches
eachmatch(r"\d{1,}", txt) |> getAllMatches
eachmatch(r"\d{1, }", txt) |> getAllMatches # extra space, empty Vec as result
eachmatch(r"$\d{1,}", txt) |> getAllMatches
eachmatch(r"\$\d{1,}", txt) |> getAllMatches

eachmatch(r"\$\d{1,}", txt) |> getAllMatches |>
vecStrDollars -> replace.(vecStrDollars, "\$" => "") |>
vecStrNumbers -> parse.(Int, vecStrNumbers) |>
sum

### Example 3
Rnd.seed!(9)
telNums = [join(Rnd.rand(string.(0:9), 9)) for _ in 1:3]

replace.(telNums, r"(\d{3})(\d{3})(\d{3})" => s"\1-\2-\3")

### Example 4
camelCasedWords = ["helloWorld", "niceToMeetYou", "translateToEnglish"]

eachmatch.(r"([A-Z])", camelCasedWords) .|> getAllMatches

# the following line throws an error
# replace.(camelCasedWords, r"([A-Z])" => s"\l\1")
replace.(camelCasedWords, r"[A-Z]" => lowercase)
replace.(camelCasedWords, r"[A-Z]" => AtoZ -> "_" * lowercase(AtoZ))
replace.(camelCasedWords, r"[A-Z]" => AtoZ -> "_$(lowercase(AtoZ))")


snakeCasedWords = ["hello_world", "nice_to_meet_you", "translate_to_english"]

replace.(snakeCasedWords, r"_[a-z]" => _atoz -> uppercase(_atoz[2:end]))
# or
replace.(snakeCasedWords, r"_[a-z]" => _atoz -> uppercase(strip(_atoz, '_')))

# Solutions

## Task 1
datesMMDDYYYY = ["01.04.2025", "11.01.2018", "12.31.1999", "03.20.2026"]
replace.(datesMMDDYYYY, r"(\d{2})\.(\d{2})\.(\d{4})" => s"\3-\1-\2")

## Task 2
txt = getTxtFromFile("./loremMail.txt");
println(txt)

eachmatch(r"[A-z0-9._\-]+@[A-z0-9._\-]+", txt) |> getAllMatches |> unique

## Task 3
# random names
names = ["Mary Johnson", "Eve Smith", "Tom Brown"]

replace.(names, r"([A-z]+) ([A-z]+)" => s"\2, \1")
replace.(names, r"([A-z]+) ([A-z]+)" => s"\2, \1") |> sort

# random names
names = [
    "Jane Johnson",
    "Mary Jane Doe",
    "Peter Smith",
    "Adam Tom Brown"
]

eachmatch.(r" [A-z]+ ", names) .|> getAllMatches

replace.(names, r" ([A-Z])[a-z]+ " => s" \1. ")

replace.(names, r" ([A-Z])[a-z]+ " => s" \1. ") |>
abbrevNames -> replace.(abbrevNames, r"([A-z .]+) ([A-z]+)" => s"\2, \1")

replace.(names, r" ([A-Z])[a-z]+ " => s" \1. ") |>
abbrevNames -> replace.(abbrevNames, r"([A-z .]+) ([A-z]+)" => s"\2, \1") |>
sort

## Task 4
nums = [0, 1, 12, 123, 1234, 12345, 123456, 1234567, 12345678, 123456789]

replace.(string.(nums), r"(\d{3})" => s"\1,")

replace.(reverse.(string.(nums)), r"(\d{3})" => s"\1,")

replace.(reverse.(string.(nums)), r"(\d{3})" => s"\1,") |>
reversedNums -> replace.(reversedNums, r",$" => "") .|> reverse

function fmtMoney(n::Int)::Str
    @assert n >= 0 "n must be >= 0"
    result::Str = replace(reverse(string(n)), r"(\d{3})" => s"\1,")
    return replace(result, r",$" => "") |> reverse
end

fmtMoney.(nums) .* " USD"

function getDollarsCents(money::Flt)::Tuple{Int, Int}
    @assert money >= 0 "money must be >= 0"
    integralPart::Int = floor(Int, money)
    decimalPart::Flt = money % 1
    return (integralPart, round(Int, decimalPart*100))
end

function fmtMoney(n::Flt)::Str
    @assert n >= 0 "n must be >= 0"
    dollars::Int, cents::Int = getDollarsCents(n)
    result::Str = fmtMoney(dollars)
    return string(result, ".", cents)
end

nums = [0, 0.1, 1, 1.2, 12., 12.34, 123.456, 1234, 12345, 12345.67, 123456.7, 1234567.89]
fmtMoney.(nums) .* " USD"
