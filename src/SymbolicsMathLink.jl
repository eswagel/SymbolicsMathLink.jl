module SymbolicsMathLink

using Symbolics
using MathLink
using SpecialFunctions

#Types that could be used in MathLink
const Mtypes = Union{MathLink.WTypes,Int8,Int16,Int32,Int64,Int128,UInt8,UInt16,UInt32,UInt64,UInt128,Float16,Float32,Float64,ComplexF16,ComplexF32,ComplexF64,Rational,String}

#Turn a piecewise function from MathLink into a ifelse function
include("Header/DecodePiecewise.jl")

#Dictionaries that map the Mathematica function name to the Julia function name and vice versa
include("Header/Dictionaries.jl")

#Trying to enforce some type stability
include("Header/numize_if_not_vector.jl")

#Convert the Julia Symbolics to Mathematica
include("Header/expr_to_mathematica.jl")

#Convert the Mathematica to Julia Symbolics
include("Header/mathematica_to_expr.jl")

#The main function that calls Mathematica on Symbolic objects
include("wcall.jl")

end
