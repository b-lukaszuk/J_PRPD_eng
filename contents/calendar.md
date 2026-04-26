# Calendar {#sec:calendar}

In this chapter I used the following libraries.

```jl
s2 = """
import Dates as Dt # internal library
"""
sc(s2)
```

Still, once you read the problem description you may decide to do otherwise.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/BS_wJ_eng/tree/main/code_snippets/calendar)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:calendar_problem}

A Gnu/Linux operating system comes with a bunch of
[utilities](https://en.wikipedia.org/wiki/Util-linux) that help with an everyday
life. One of them is [cal](https://en.wikipedia.org/wiki/Cal_(command)) command
that displays a calendar. Let's try to mimic a fraction of its power.
Write a program that prints a calendar for a given month that looks similarly
to:

```
> cal Jun 2025 # shell command (output starts 1 line below)
     June 2025
Su Mo Tu We Th Fr Sa
 1  2  3  4  5  6  7
 8  9 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30
```

Use it to tell on which day of the week you were born.

Alternatively, assume that the Gregorian calendar has been applied throughout
the whole [Common Era](https://en.wikipedia.org/wiki/Common_Era) and based on
that say:

- on what day of the week was Jesus born (assume: Dec 25, year 1)?
- on what day of the week was the world supposed to come to an end (assume: Dec
  21, year 2012, but you [got plenty dates to choose
  from](https://en.wikipedia.org/wiki/List_of_dates_predicted_for_apocalyptic_events))?
- on what day of the week will the next millennium start (assume: Jan 1, 3000)?

Try not to employ the built-in
[Dates](https://docs.julialang.org/en/v1/stdlib/Dates/) module in your
solution (unless you have to). Still, you may use it to verify your results,
e.g. in order to know on which day did this year start just type:

```jl
s = """
import Dates as Dt

d = Dt.Date(2025, 1, 1)
Dt.dayname(d)
"""
sco(s)
```

BTW. You may use the above day as a reference point.

## Solution {#sec:calendar_solution}

First, let's begin by defining a few rather self explanatory constants (`const`)
that we will use throughout our program.

```jl
s = """
DAYS_PER_WEEK = 7
DAYS_PER_MONTH = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
DAYS_PER_MONTH_LEAP = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
SHIFT_YR = 365
SHIFT_YR_LEAP = 366
WEEKDAYS_NAMES = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
MONTHS_NUM_2_NAME = Dict(
    1 => "January", 2 => "February", 3 => "March",
    4 => "April", 5 => "May", 6 => "June", 7 => "July",
    8 => "August", 9 => "September", 10 => "October",
    11 => "November", 12 => "December")
MONTHS_NAME_2_NUM = Dict(
    "Jan" => 1, "Feb" => 2, "Mar" => 3,
    "Apr" => 4, "May" => 5, "Jun" => 6, "Jul" => 7,
    "Aug" => 8, "Sep" => 9, "Oct" => 10,
    "Nov" => 11, "Dec" => 12)
"""
replace(sc(s), "DAYS_PER_WEEK =" => "const DAYS_PER_WEEK =",
	"DAYS_PER_MONTH =" => "const DAYS_PER_MONTH =",
	"DAYS_PER_MONTH_LEAP =" => "const DAYS_PER_MONTH_LEAP =",
	"SHIFT_YR =" => "const SHIFT_YR =",
	"SHIFT_YR_LEAP =" => "const SHIFT_YR_LEAP =",
	"WEEKDAYS_NAMES =" => "const WEEKDAYS_NAMES =",
	"MONTHS_NUM_2_NAME =" => "const MONTHS_NUM_2_NAME =",
	"MONTHS_NAME_2_NUM =" => "const MONTHS_NAME_2_NUM ="
)
```

> Note. Using `const` with mutable containers like vectors or dictionaries
> allows to change their contents later on, e.g., with `push!`. So the `const`
> used here is more like a convention, a signal that we do not plan to change
> the containers in the future. If we really wanted an immutable container then
> we should consider a(n) (immutable) tuple. Anyway, some programming languages
> suggest that `const` names should be declared using all uppercase characters
> to make them stand out. Here, I follow this convention.

As you can see from the output of `cal Jan 2025` (see @sec:calendar_problem) we
get a rectangular printout with 7 columns and `x` rows. Clearly, the number of
elements is a multiple of 7. So, let's write a function that determines how
many elements should be in our rectangle.

```jl
s = """
function getMultOfYGtEqX(x::Int, y::Int=DAYS_PER_WEEK)::Int
    @assert x > 0 && y > 0 "x and y must be > 0"
    @assert x >= y "x must be >= y"
    q::Int, r::Int = divrem(x, y) # quotient, reminder
    return r == 0 ? x : y*(q+1)
end
"""
sc(s)
```

To that end we wrote `getMultOfYGtEqX` that, as its name implies, returns the
multiple of `y` that is greater than or equal to `x`. First, thanks to `divrem`
function, we get the quotient (`q` - the number of 'full' `y`s is inside of `x`)
and the reminder (`r` - the rest after the integer division) after dividing `x`
by `y`. If `x` is evenly divisible by `y` (`r == 0 ?`) then our result is just
`x` (`x` is the multiple of `y`). Otherwise, we multiply `y` by the quotient
plus 1 (`y*(q+1)`).

We will use it (`getMultOfYGtEqX`) to get our days for a given month padded with
zeros.

```jl
s = """
# 1 - Sunday, 7 - Saturday
function getPaddedDays(nDays::Int, fstDay::Int)::Vec{Int}
    @assert 0 < fstDay < 8 "fstDay must be in range [1-7]"
    daysFront::Int = fstDay - 1
    days::Vec{Int} = zeros(getMultOfYGtEqX(nDays+daysFront, DAYS_PER_WEEK))
    days[fstDay:(fstDay+nDays-1)] = 1:nDays
    return days
end

function vec2matrix(v::Vec{T}, r::Int, c::Int,
                    byRow::Bool)::Matrix{T} where T
    @assert (r > 0 && c > 0) "r and c must be positive integers"
    @assert (length(v) == r*c) "length(v) must be equal to r*c"
    m::Matrix{T} = Matrix{T}(undef, r, c)
    stepBegin::Int = 1
    stepSize::Int = (byRow ? c : r) - 1
    for i in 1:(byRow ? r : c)
        if byRow
            m[i, :] = v[stepBegin:(stepBegin+stepSize)]
        else
            m[:, i] = v[stepBegin:(stepBegin+stepSize)]
        end
        stepBegin += (stepSize + 1)
    end
    return m
end
"""
sc(s)
```

All that we need for that is to know the number of days in a given month
(`nDays`) and what is the first day (`fstDay`, where 1 is Sunday and 7 is
Saturday). We use the above as the arguments to `getPaddedDays`. The function
creates a vector of `zeros` that contains number of elements that is a multiple
of 7 (`DAYS_PER_WEEK`). The vector length is determined by `getMultOfYGtEqX` and
is at least `nDays+daysFront` long. We fill the vector (starting at `fstDay`)
with digits for all the days (`1:nDays`). Finally, we return `days`.

Afterwards, we want to put the vector (result of `getPaddedDays`) into a matrix
with 7 columns (`DAYS_PER_WEEK`) and the appropriate number of rows. For that we
wrote `vec2matrix`, that unlike the built in
[reshape](https://docs.julialang.org/en/v1/base/arrays/#Base.reshape), will
allow us to put the vector (`v`) into the matrix (`m`) row by row
(when `byRow = true`).

Let's see how it works for January 2025.

```jl
s = """
jan2025 = getPaddedDays(31, 4)
vec2matrix(jan2025, Int(length(jan2025) / DAYS_PER_WEEK),
	DAYS_PER_WEEK, true)
"""
sco(s)
```

Pretty good, and how about this month (June 2025).

```jl
s = """
jun2025 = getPaddedDays(30, 1)
vec2matrix(jun2025, Int(length(jun2025) / DAYS_PER_WEEK),
	DAYS_PER_WEEK, true)
"""
sco(s)
```

It appears to be working as intended.

Time to format that output a little.

```jl
s = """
# 1 - Sunday, 7 - Saturday
function getFmtMonth(fstDayMonth::Int, nDaysMonth::Int,
                     month::Int, year::Int)::Str
    @assert 1 <= fstDayMonth <= 7 "fstDayMonth must be in range [1-7]"
    @assert 28 <= nDaysMonth <= 31 "nDaysMonth must be in range [28-31]"
    @assert 1 <= month <= 12 "month must be in range [1-12]"
    @assert 1 <= year <= 4000 "year must be in range [1-4000]"
    topRow2::Str = join(WEEKDAYS_NAMES, " ")
    topRow1::Str = center(
        string(MONTHS_NUM_2_NAME[month], " ", year), length(topRow2))
    days::Vec{Str} = string.(getPaddedDays(nDaysMonth, fstDayMonth))
    days = replace(days, "0" => " ")
    m::Matrix{Str} = vec2matrix(
        days, Int(length(days)/daysPerWeek), DAYS_PER_WEEK, true)
    fmtDay(day) = lpad(day, 2)
    fmtRow(row) = join(map(fmtDay, row), " ")
    result::Str = ""
    for r in eachrow(m)
        result *= fmtRow(r) * "\\n"
    end
    return topRow1 * "\\n" * topRow2 * "\\n" * result
end
"""
sc(s)
```

We begin with a couple of sanity checks (`@assert` statements). Next, we `join`
`WEEKDAYS_NAMES` into a one long string separated with spaces (`" "`) to get a
row just on top of the days (`topRow2`). Above that (`topRow1`) we will place a
month name (`MONTHS_NUM_2_NAME[month]`) and a `year` (like `"January 2025"`), which
we `center` with the function developed in @sec:pascals_triangle_solution.
Finally, the consecutive rows will be occupied by `days`
written with the Arabic numerals and expressed as vector of strings
(`days::Vec{Str}`). However, we replace the zeros (`"0"` used for padding) with
spaces and put them (`days`) into a matrix (`m`). All that's left to do is to
define day (`fmtDay`) and row (`fmtRow`) formatters (inline functions) for our
matrix. We proceed by building our `result` row by row (`result *= fmtRow(r) *
"\n"`). Finally, we return a formatted month by gluing everything together
(`topRow1 * "\n" * topRow2 * "\n" * result`). Let's take a sneak peak.

January 2025:

```
getFmtMonth(4, 31, 1, 2025)
    January 2025
Su Mo Tu We Th Fr Sa
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31
```

and June 2025:

```
getFmtMonth(1, 30, 6, 2025)
      June 2025
Su Mo Tu We Th Fr Sa
 1  2  3  4  5  6  7
 8  9 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30
```

At this point we're basically done. That is, if we wanted to take a shortcut
and rely on the built-in `Dates` module to calculate a day of the week for us
(for details see @sec:calendar_problem). Of course, a(n) (over)zealous Julia
programmer would never do no such a thing. So let's try to figure it out on our
own with `getShiftedDay`.

```jl
s = """
# 1 - Sunday, 7 - Saturday
function getShiftedDay(curDay::Int, by::Int)::Int
    @assert 1 <= curDay <= 7 "curDay not in range [1-7]"
    newDay::Int = curDay
    shift::Int = abs(by) % DAYS_PER_WEEK
    move::Int = by < 0 ? -1 : 1
    for _ in 1:shift
        newDay += move
        newDay = newDay < 1 ? 7 :
            (newDay > 7 ? 1 : newDay)
    end
    return newDay
end
"""
sc(s)
```

The function accepts the current day (`curDay`) and a shift (`by`). That last
parameter is the number of days before (negative values) or after (positive
values) `curDay`. The actual `shift` is calculated using the [modulo
operator](https://docs.julialang.org/en/v1/base/math/#Base.rem) (`%`), since a
shift by let's say +15 days is actually a shift by two weeks (which we may
ignore) and 1 day (`abs(15) % 7` is 1). Next, we make as many moves (day before
is `-1`, day after is `1`) as indicated by `shift`
(`for _ in 1:shift`). However, if we stepped out of the range to the left
(`newDay < 1 ?`), we begin from the other side (`7`th day of the
week). Alternatively (`:`), if we stepped out of range to the right (`newDay > 7
?`), we begin from the start (`1`). Otherwise, we leave `newDay` as it was (`:
newDay`). Notice, however, that if `shift` is equal to 0 then the code in the
`for` loop will not be executed and `newDay` equal to `curDay` will be returned
(which is what we want, e.g. for `by = 0` or `by = 14`).

Now, `getFmtMonth` and `getPaddedDays` require a day of the week with
which a month starts plus the number of days in that month. Let's use our
`getShiftedDay` to calculate that for any month in a given year.

```jl
s1 = """
# 1 - Sunday, 7 - Saturday
# returns (1st day of month, num of days in this month)
function getMonthData(dayJan1::Int, month::Int, leap::Bool)::Tuple{Int, Int}
    @assert 1 <= dayJan1 <= 7 "day not in range [1-7]"
    @assert 1 <= month <= 12 "month not in range [1-12]"
    curDay::Int = dayJan1
    daysInMonths::Vec{Int} = leap ? DAYS_PER_MONTH_LEAP : DAYS_PER_MONTH
    if month == 1
        return (dayJan1, daysInMonths[month])
    end
    for m in 2:month
        curDay = getShiftedDay(curDay, daysInMonths[m-1])
    end
    return (curDay, daysInMonths[month])
end
"""
sc(s1)
```

The function is rather simple. If we want to know when a given month begins we
just shift `curDay` (initialized with `dayJan1`) by as many days as there were
in the previous month (`daysInMonths[m-1]`) for all the previous months up to
this one (`for m in 2:month`).

If we can do such a shift for a month in a given year, we can also do it for any
month in any year.

```jl
s2 = """
# 1 - Sunday, 7 - Saturday
# returns (1st day of month, num of days in this month)
function getMonthData(yr::Int, month::Int)::Tuple{Int, Int}
    @assert 1 <= yr <= 4000 "yr not in range [1-4000]"
    @assert 1 <= month <= 12 "month not in range [1-12]"
    curDay::Int = 4 # 1st Jan 2025 (reference point) was Wednesday
    start::Int = yr <= 2025 ? 2025-1 : 2025+1
    step::Int = yr <= 2025 ? -1 : 1
    yrShift::Int = 0
    for y in start:step:yr
        yrShift = isLeap(y) ? SHIFT_YR_LEAP : SHIFT_YR
        curDay = getShiftedDay(curDay,  yrShift * step)
    end
    return getMonthData(curDay, month, isLeap(yr))
end
"""
sc(s2)
```

We begin, by setting a reference point (`curDay`) to be January 1, 2025 (let's
say that we've got a calendar on a wall in front of us that we can rely on for
that information). Next, thanks to the for loop (and `getShiftedDay`) we figure
out on which day of the week a given year (`yr`) starts (we get there year by
year with `for y in start:step:yr`). Of course, we take into account leap years
(see `isLeap` from @sec:leap_year_solution) if there are any. Finally
(`return`), we use the previously defined `getMonthData` method, to get the
necessary information (starting day, days in month) for a month we are looking for.

All that's left to do is to pack it all into `getCal` wrapper for the ease of
use.

```jl
s = """
function getCal(month::Int, yr::Int)::Str
	# ... - unpacks tuple into separate values
    return getFmtMonth(getMonthData(yr, month)..., month, yr)
end

function getCal(month::Str, yr::Int)::Str
    m::Int = monthsName2Num[month]
    return getCal(m, yr)
end
"""
sc(s)
```

Time for the first swing.

```
getCal("Jan", 2025)
    January 2025
Su Mo Tu We Th Fr Sa
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31
```

And now for the questions.

On what day of the week was Jesus born (assume: Dec 25, year 1)?

```
getCal("Dec", 1)
     December 1
Su Mo Tu We Th Fr Sa
                   1
 2  3  4  5  6  7  8
 9 10 11 12 13 14 15
16 17 18 19 20 21 22
23 24 25 26 27 28 29
30 31
```

On what day of the week was the world supposed to come to an end (assume: Dec
21, year 2012)?

```
getCal("Dec", 2012)
    December 2012
Su Mo Tu We Th Fr Sa
                   1
 2  3  4  5  6  7  8
 9 10 11 12 13 14 15
16 17 18 19 20 21 22
23 24 25 26 27 28 29
30 31
```

On what day of the week will the next millennium start (assume: Jan 1, 3000)?

```
getCal("Jan", 3000)
    January 3000
Su Mo Tu We Th Fr Sa
          1  2  3  4
 5  6  7  8  9 10 11
12 13 14 15 16 17 18
19 20 21 22 23 24 25
26 27 28 29 30 31
```

Of course, the above results should be correct under the assumption that [the
Gregorian calendar](https://en.wikipedia.org/wiki/Gregorian_calendar) has been
uniformly applied throughout the whole [Common
Era](https://en.wikipedia.org/wiki/Common_Era). Needless to say, that was not
the case, so I wouldn't rely on `getCal` too much for your time travel.
