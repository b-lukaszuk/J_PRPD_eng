import Symbolics as Sym

# WARNING
# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# solution with built in matrix algebra
variables = [
    1 1; # equation 1, 1 bat + 1 ball
    1 -1 # equation 2, 1 bat - 1 ball
]

prices = [1.1, 1] # equation 1 (= 1.1), equation 2 (= 1);

result = inv(variables) * prices
round.(result, digits=4)
# or
result = variables \ prices
round.(result, digits=4)

# solution with Symbolics.jl library
Sym.@variables bat ball;
result = Sym.symbolic_linear_solve(
    [
        bat + ball ~ 1.1,
        bat - ball ~ 1
    ],
    [bat, ball],
    simplify=true
)

map(x -> round(x.val, digits=4), result)
