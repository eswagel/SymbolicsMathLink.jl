"""
    wcall([returnJulia::Val{bool},] head::AbstractString, args...; returnJulia=Val(true), kwargs...)

    Calls a Mathematica function on arguments of Symbolics and other Julia types, converting those arguments to Mathematica, and then changing the result back to Julia.

    # Arguments
    - `returnJulia`: Optional. If `Val(false)`, the function will return a Mathematica MathLink object instead of converting back to Julia.
    - `head::AbstractString`: The name of the Mathematica function to call.
    - `args...`: The arguments to the Mathematica function. These can be Symbolics, Julia types, or Mathematica types.
    - `kwargs...`: Keyword arguments to the Mathematica function. These can be Symbolics, Julia types, or Mathematica types.

    # Returns
    - If `returnJulia` is `false`, returns a Mathematica MathLink object representing the result of the Mathematica function.
    - If `returnJulia` is `true` (default), returns a Julia expression representing the result of the Mathematica function.

    # Examples
    ```julia
    julia> wcall("Solve", x^2 + 2x + 1 == 0, returnJulia=false)
    MathLink.MathLinkObject(...)

    julia> wcall("Solve", x^2 + 2x + 1 == 0)
    2-element Array{Sym,1}:
    -1 + x
    -1 - x
    ```
"""
function wcall(::Val{false}, head::AbstractString, args...; kwargs...)
    mathematica_result = wcall(head, args...; kwargs...)
    return convert_to_julia(mathematica_result)
end

 wcall(::Val{true}, head::AbstractString, args...; kwargs...)=begin
    return weval(MathLink.WSymbol(head)(args...; kwargs...))
end

wcall(head::AbstractString, args...; kwargs...) = wcall(Val(true), head, args...; kwargs...)

export wcall