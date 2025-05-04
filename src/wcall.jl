function wcall(returnJulia::Union{Val{true}, Val{false}}, head::AbstractString, args...; kwargs...)
"""
        wcall([returnJulia::Val{bool},] head::AbstractString, args..., kwargs...)

    Calls a Mathematica function on arguments of Symbolics and other Julia types, converting those arguments to Mathematica, and then changing the result back to Julia.

    # Arguments
    - `returnJulia`: Optional. If `Val(false)`, the function will return a Mathematica MathLink object instead of converting back to Julia.
    - `head::AbstractString`: The name of the Mathematica function to call.
    - `args...`: The arguments to the Mathematica function. These can be Symbolics, Julia types, or Mathematica types.
    - `kwargs...`: Keyword arguments to the Mathematica function. These can be Symbolics, Julia types, or Mathematica types.

    # Returns
    - If `returnJulia` is `Val(false)`, returns a Mathematica MathLink object representing the result of the Mathematica function.
    - If `returnJulia` is `Val(true)` (default), returns a Julia expression representing the result of the Mathematica function.

    # Examples
    ```julia
    julia> wcall(Val(false), "Solve", x^2 + 2x + 1 ~ 0)
    W`List[List[Rule[x, -1]], List[Rule[x, -1]]]`

    julia> wcall("Solve", x^2 + 2x + 1 ~ 0)
    2-element Vector{Vector{Pair{Num, Num}}}:
    [x => -1]
    [x => -1]
    ```
"""

    return wcall(returnJulia, head, expr_to_mathematica.(args)...; kwargs...)
end
wcall(::Val{true}, head::AbstractString, args::Vararg{Mtypes}; kwargs...) = begin
    mathematica_result = wcall(Val(false), head, args...; kwargs...)
    return mathematica_to_expr(mathematica_result)
end

wcall(::Val{false}, head::AbstractString, args::Vararg{Mtypes}; kwargs...) = begin
    return weval(MathLink.WSymbol(head)(args...; kwargs...))
end

wcall(head::AbstractString, args...; kwargs...) = wcall(Val(true), head, args...; kwargs...)

export wcall
