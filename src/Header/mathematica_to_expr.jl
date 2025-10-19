mathematica_to_expr_vector_checker(head::AbstractString,args::Vector,::Nothing)=begin
    variables = Symbol.(args)
    varname = Symbol(head)
    (vars, ) = @variables $varname(variables...)
    vars
end
mathematica_to_expr_vector_checker(head::AbstractString,args::Vector,m::RegexMatch)=begin
    varname=Symbol(m[1])
    indices = map(s -> parse(Int8, s), split(replace(m[2]," "=>""), ",")) 
    ranges = map(ind -> 1:ind, indices)
    (vars,)=Symbolics.scalarize.(Symbolics.@variables $varname(mathematica_to_expr.(args)...)[ranges...])
    indices = length(indices) == 1 ? indices[1] : indices
    vars[indices...]
end
mathematica_to_expr_differential_checker(head::MathLink.WExpr,args::Vector)::Num=begin
    if head.head.head.name=="Derivative"
        return (Differential(Symbolics.variable(args[1]))^head.head.args[1])(eval(Symbol(head.args[1])))
    else
        throw(ArgumentError("Not a derivative: problem in mathematica_to_expr_differential_checker"))
    end
end
mathematica_to_subscript_expr(symb::MathLink.WSymbol,indices::Vector)=begin
    ranges = map(ind -> 1:ind, indices)
    varname = Symbol(symb)
    (vars,)= Symbolics.scalarize.(Symbolics.@variables $varname[ranges...])
    indices = length(indices) == 1 ? indices[1] : indices
    vars[indices...]
end

mathematica_to_expr_differential_checker(head::MathLink.WSymbol,args::Vector)=begin
    if head.name=="Power" && isa(args[1],MathLink.WSymbol) && args[1].name=="E"
        return exp(mathematica_to_expr.(args[2:end])...)
    elseif head.name=="Subscript" && isa(args[1],MathLink.WSymbol)
        return mathematica_to_subscript_expr(args[1], args[2:end])
    elseif haskey(MATHEMATICA_TO_JULIA_FUNCTIONS, head.name)
        stuff = mathematica_to_expr.(args)
        return MATHEMATICA_TO_JULIA_FUNCTIONS[head.name](stuff...)
    else
        m=match(r"Subscript\[\s*(\w+?),\s*(\d+(?:\s*,\s*\d+)*)\]",head.name)
        return mathematica_to_expr_vector_checker(head.name,args,m)
        #return mathematica.head.name,getproperty.(mathematica.args,Ref(:name))...)
    end
end
mathematica_to_expr_differential_checker(head,args::Tuple)=mathematica_to_expr_differential_checker(head,[args...])
function mathematica_to_expr(mathematica::MathLink.WExpr)
    """Converts a MathLink.WExpr to a Julia expression, checking if it's a differential"""
    mathematica_to_expr_differential_checker(mathematica.head,mathematica.args)
end
mathematica_to_expr(symbol::MathLink.WSymbol)=mathematica_to_expr(symbol,match(r"Subscript\[\s*(\w+?),\s*(\d+(?:\s*,\s*\d+)*)\]",symbol.name))
mathematica_to_expr(symbol::MathLink.WSymbol,::Nothing)=begin
    if haskey(MATHEMATICA_TO_JULIA_FUNCTIONS, symbol.name)
        return MATHEMATICA_TO_JULIA_FUNCTIONS[symbol.name]
    else
        return Symbolics.variable(symbol.name)
    end
end
mathematica_to_expr(symbol::MathLink.WSymbol,m::RegexMatch)=begin
    varname=Symbol(m[1])
    indices = map(s -> parse(Int8, s), split(replace(m[2]," "=>""), ",")) 
    ranges = map(ind -> 1:ind, indices)
    (vars,)=Symbolics.scalarize.(Symbolics.@variables $varname[ranges...])
    indices = length(indices) == 1 ? indices[1] : indices
    vars[indices...]
end
mathematica_to_expr(mathematica::MathLink.WReal)=mathematica_to_expr(weval(W"N"(mathematica)))
mathematica_to_expr(num::T) where T<:Number=begin
    rounded = round(num)
    if abs(rounded-num)< 1e-10
        return rounded
    else
        return num
    end
end
mathematica_to_expr(mathematica::T) where T<:AbstractString=mathematica

export mathematica_to_expr