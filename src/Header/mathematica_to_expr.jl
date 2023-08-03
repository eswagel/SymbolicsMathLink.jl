mathematica_to_expr_vector_checker(head::AbstractString,args::Vector,::Nothing)=begin
    varname=Symbol(head)
    (vars,)=Symbolics.@variables varname
    vars
end
mathematica_to_expr_vector_checker(head::AbstractString,args::Vector,m::RegexMatch)=begin
    varname=Symbol(m[1])
    (vars,)=scalarize.(Symbolics.@variables $varname(mathematica_to_expr.(args)...)[1:parse(Int8,m[2])])
    vars[parse(Int8,m[2])]
end
mathematica_to_expr_differential_checker(head::MathLink.WExpr,args::Vector)::Num=begin
    if head.head.head.name=="Derivative"
        return (Differential(Symbolics.variable(args[1]))^head.head.args[1])(eval(Symbol(head.args[1])))
    else
        throw(ArgumentError("Not a derivative: problem in mathematica_to_expr_differential_checker"))
    end
end
mathematica_to_expr_differential_checker(head::MathLink.WSymbol,args::Vector)=begin
    if head.name=="Power" && isa(args[1],MathLink.WSymbol) && args[1].name=="E"
        return exp(mathematica_to_expr.(args[2:end])...)
    elseif haskey(MATHEMATICA_TO_JULIA_FUNCTIONS, head.name)
        return MATHEMATICA_TO_JULIA_FUNCTIONS[head.name](mathematica_to_expr.(args)...)
    else
        m=match(r"(.+)■([0-9]+)",head.name)
        return mathematica_to_expr_vector_checker(head.name,args,m)
        #return mathematica.head.name,getproperty.(mathematica.args,Ref(:name))...)
    end
end
mathematica_to_expr_differential_checker(head,args::Tuple)=mathematica_to_expr_differential_checker(head,[args...])
function mathematica_to_expr(mathematica::MathLink.WExpr)
    """Converts a MathLink.WExpr to a Julia expression, checking if it's a differential"""
    mathematica_to_expr_differential_checker(mathematica.head,mathematica.args)
end
mathematica_to_expr(symbol::MathLink.WSymbol)=mathematica_to_expr(symbol,match(r"(.+)■([0-9]+)",symbol.name))
mathematica_to_expr(symbol::MathLink.WSymbol,::Nothing)=begin
    if haskey(MATHEMATICA_TO_JULIA_FUNCTIONS, symbol.name)
        return MATHEMATICA_TO_JULIA_FUNCTIONS[symbol.name]
    else
        return Symbolics.variable(symbol.name)
    end
end
mathematica_to_expr(symbol::MathLink.WSymbol,m::RegexMatch)=begin
    varname=Symbol(m[1])
    (vars,)=scalarize.(Symbolics.@variables $varname[1:parse(Int8,m[2])])
    vars[parse(Int8,m[2])]
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