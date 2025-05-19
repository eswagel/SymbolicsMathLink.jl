# SymbolicsMathLink

SymbolicsMathLink.jl is a Julia package that provides a MathLink interface to Mathematica for symbolic computations. It allows you to call Mathematica functions on Julia Symbolics expressions. Extensive testing has been done to ensure type stability and other optimizations. This project came out of my senior thesis.

For example, Mathematica excels at solving complicated equations and differential equations, functionalities that cannot easily be done in Julia. The `wcall` function allows Mathematica's operations to be performed seamlessly on Julia Symbolics, with minimum effort on the front end.

## Installation

To run SymbolicsMathLink.jl, both the [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl) package and the [MathLink.jl](https://github.com/JuliaInterop/MathLink.jl) package must be installed **and configured**. That means you must have an active subscription to Mathematica or the free Wolfram Engine installed on your computer. See details in MathLink.jl for more information, but be aware that it takes some effort.

To install SymbolicsMathLink.jl, run the following command in the Julia REPL:

```julia
julia> import Pkg;
julia> Pkg.add("SymbolicsMathLink")
```

## Usage

Simply call `wcall` on a Julia symbolics object, naturally filling in the arguments.

```julia
julia> using SymbolicsMathLink

julia> @variables x;
julia> expr = x^2 + x - 1;

julia> result = wcall("Solve", expr~0)
2-element Array{Num,1}:
    -1 + x
    1 + x
```

Derivatives and array variables are also supported:
```julia
julia> @variables vars(x)[1:2];
julia> expr = Differential(x)(vars[1]) + 2
2 + Differential(x)((vars(x))[1])
julia> result = wcall("DSolveValue", expr~0, vars[1], x)
C_1 - 2x
```

Additionally, piecewise functions are supported through `ifelse`.


The package's main export is the function `wcall`:
```julia
wcall([returnJulia::Val{bool},] head::AbstractString, args...; kwargs...)
```
`head` is the name of the Mathematica function to be called, for example: `"Solve"`, or `"DSolve"`, etc.
`args` are the arguments to be passed to the `head` function in Mathematica. These will be converted automatically to MathLink objects.
`kwargs` are the keyword arguments to be passed to the `head` function in Mathematica. These will be converted automatically to MathLink objects.

If `returnJulia` is `Val(true)` (default), `wcall` converts the Mathematica result back to Julia Symbolics, and you don't need to worry at all about what's going on under the hood. If you want to manipulate the MathLink result further for any reason, pass `Val(false)` as the first argument and it will return the result as a MathLink object.

### Converting Symbolics and Mathematica
Under the hood, `wcall` is converting the Julia Symbolics to MathLink expressions, calling `MathLink.weval` to run Mathematica, and then (optionally) converting back to Symbolics. To make those conversions directly, use:
```julia
expr_to_mathematica(juliaSymbolicExpression)
mathematica_to_expr(W`Some Mathematica expression`)
```

As an example,
```julia
julia> @variables x y
julia> expr_to_mathematica(x^2 + sqrt(y))
W`Plus[Power[x, 2], Sqrt[y]]`
```

or 

```julia
julia> mathematica_to_expr(W`Plus[Power[x, 2], Sqrt[y]]`)
x^2 + sqrt(y)
```

## Caveats
Not every Mathematica function is supported, although for many functions it may not be particularly time consuming to add that functionality. Please make a pull request or issue on Github if you encounter one of these examples.

Two key exceptions are Mathematica's `&` and `|` operators. There are no analogs for that functionality in Julia's Symbolics, and therefore those cannot be converted.

## Use Case: Evaluating Long Functions

I found the function surprisingly useful in evaluating functions for which the code itself is long. For example, if one were to symbolically calculate the 1000th Hermite polynomial:
```julia 
julia> hermite = Hermite(x,1000); #Assuming existing function called Hermite
julia> build_function(hermite,x);
julia> hermite(10)

```
Because the `hermite` Symbolic expression is a very long AST, function compilation takes a long time upon first evaluation. Converting to Mathematica and evaluating can actually lead to surprising benefits:
```julia
julia> wcall("ReplaceAll",hermite,[x,10])
```


## Contributing

Contributions to SymbolicsMathLink.jl are welcome! To contribute, please submit a pull request or raise an issue.

## License

SymbolicsMathLink.jl is licensed under the [MIT License](https://opensource.org/licenses/MIT).
