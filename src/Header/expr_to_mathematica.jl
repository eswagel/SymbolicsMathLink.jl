function expr_to_mathematica(expr::Expr)::Mtypes
    """ Convert a Julia expression to a MathLink expression using recursion"""
    expr_to_mathematica(expr.head,expr.args)
end
#Differentials have to be handled specially
expr_to_mathematica_differential_checker(function_head::Symbol,args::Vector,::Nothing)::MathLink.WExpr=W"$(string(function_head))"(expr_to_mathematica.(args)...)
expr_to_mathematica_differential_checker(function_head::Symbol,args::Vector,m::RegexMatch)::MathLink.WExpr=begin
    return MathLink.WSymbol("D")(expr_to_mathematica.(args)...,MathLink.WSymbol("$(m[1])"))
end
#Variables that are vectors have to be handled specially, using the "■" character to symbolize that it's a vector
expr_to_mathematica_vector_handler(expr::MathLink.WSymbol,index::Integer)=MathLink.WSymbol("$(expr.name)■$(index)")
expr_to_mathematica_vector_handler(expr::MathLink.WExpr,index::Integer)=begin
    #If expr.head.name contains any of ■₁₂₃₄₅₆₇₈₉₀, throw an error
    #Regexmatch for any of the above characters
    m = match(r"■[₁₂₃₄₅₆₇₈₉₀]",expr.head.name)
    if m!=nothing
        #Throw an error with that character
        throw(ArgumentError("The character $(m[1]) is not allowed in a variable name"))
    end

    MathLink.WSymbol("$(expr.head.name)■$(index)")(expr.args...)
end
#The main function
expr_to_mathematica(function_head::Symbol,args::Vector)::Mtypes=begin
    """ Convert a Julia expression head and args to a MathLink expression"""
    
    if function_head==:call
        return expr_to_mathematica(Symbol(args[1]),args[2:end])
    elseif function_head==:inv #Symbolics uses inv instead of ^-1
        return MathLink.WSymbol("Power")(expr_to_mathematica(args[1]),-1)
    elseif function_head==:getindex
        would_be = expr_to_mathematica(args[1])
        return expr_to_mathematica_vector_handler(would_be, args[2])
    elseif function_head==:if
        #If gets turned into piecewise
        cond = expr_to_mathematica(args[1])
        ifval = expr_to_mathematica(args[2])
        elseval = expr_to_mathematica(args[3])
        return MathLink.WSymbol("Piecewise")(MathLink.WSymbol("List")(MathLink.WSymbol("List")(ifval, cond)),elseval)
    elseif haskey(JULIA_FUNCTIONS_TO_MATHEMATICA, function_head)
        #If it's a function that I've mapped to a Mathematica function
        return MathLink.WSymbol("$(JULIA_FUNCTIONS_TO_MATHEMATICA[function_head])")(expr_to_mathematica.(args)...)
    else
        fstring=string(function_head)
        m = match(r"Differential\(([^)]*)\)",fstring)
        #Check if it's a differential and handle accordingly
        return expr_to_mathematica_differential_checker(function_head,args,m)
    end
end
expr_to_mathematica_symbol_vector_checker(str::String,m::Nothing)=MathLink.WSymbol(str)
expr_to_mathematica_symbol_vector_checker(str::String,m::RegexMatch)=begin
    replacements=("₁"=>"1","₂"=>"2","₃"=>"3","₄"=>"4","₅"=>"5","₆"=>"6","₇"=>"7","₈"=>"8","₉"=>"9","₀"=>"0")
    MathLink.WSymbol("$(m[1])■$(replace(m[2],replacements...))")
end
expr_to_mathematica(symbol::Symbol)::MathLink.WSymbol=begin
    if haskey(JULIA_FUNCTIONS_TO_MATHEMATICA, symbol)
        return MathLink.WSymbol(JULIA_FUNCTIONS_TO_MATHEMATICA[symbol])
    else
        symString=string(symbol)
        m=match(r"([^₁₂₃₄₅₆₇₈₉₀]*)([₁|₂|₃|₄|₅|₆|₇|₈|₉|₀]+)$",symString)
        return expr_to_mathematica_symbol_vector_checker(symString,m)
    end
end
(expr_to_mathematica(num::T)::T) where {T<:Mtypes}=num
expr_to_mathematica(eq::Equation)::MathLink.WExpr=MathLink.WSymbol("Equal")(expr_to_mathematica(Symbolics.toexpr(eq.lhs)::Union{Expr, Symbol, Int, Float64, Rational}),expr_to_mathematica(Symbolics.toexpr(eq.rhs)::Union{Expr, Symbol, Int, Float64, Rational}))
(expr_to_mathematica(vect::Vector{T})::MathLink.WExpr) where T=MathLink.WSymbol("List")(expr_to_mathematica.(vect)...)
(expr_to_mathematica(mat::Matrix{T})::MathLink.WExpr) where T = expr_to_mathematica([mat[:,i] for i in 1:size(mat,2)])
expr_to_mathematica(num::Num)::Mtypes=expr_to_mathematica(Symbolics.toexpr(num)::Union{Expr, Symbol, Int, Float64, Rational})
expr_to_mathematica(dict::Dict)::MathLink.WExpr=begin
    rules = MathLink.WExpr[]
    for (key, val) in dict
        push!(rules, MathLink.WSymbol("Rule")(expr_to_mathematica(key), expr_to_mathematica(val)))
    end
    MathLink.WSymbol("List")(rules...)
end
expr_to_mathematica(sym::Symbolics.Symbolic)::MathLink.WExpr=begin
    expr::Expr = Symbolics.toexpr(sym)::Expr
    expr_to_mathematica(expr)
end
expr_to_mathematica(st::AbstractString)::MathLink.WSymbol=MathLink.WSymbol(st)
expr_to_mathematica(x::BigFloat)=Float64(x)
expr_to_mathematica(x::Irrational)=Float64(x)