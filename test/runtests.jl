using SymbolicsMathLink
using Symbolics
using MathLink
using Test

@testset "SymbolicsMathLink.jl" begin
    # Test 1: Basic functionality
    @test SymbolicsMathLink.wcall("Part", [1, 2], 2) == 2

    # Test 2: Test with different arguments
    @test SymbolicsMathLink.wcall("Part", [3, 4, 5], 3) == 5

    # Test 3: Test with nested lists
    @test SymbolicsMathLink.wcall("Part", [[1, 2], [3, 4]], 2) == [3, 4]

    # Test 4: Test with strings
    @test SymbolicsMathLink.wcall("StringJoin", ["Hello", " ", "World"]) == "Hello World"

    # Test 5: Test with returnJulia=true
    @test SymbolicsMathLink.wcall(Val(true), "Plus", 1, 2) == 3

    # Test 6: Test with returnJulia=false using Symbolics variables
    @variables x y
    @test SymbolicsMathLink.wcall(Val(false), "Times", x, y) == W`Times[x, y]`

    # Test 7: Test with keyword arguments
    @test SymbolicsMathLink.wcall("ReplaceAll", [1, 2, 3], 2 => 4) == [1, 4, 3]

    # Test 8: Test with a pair
    pair = "a" => 1
    @test SymbolicsMathLink.expr_to_mathematica(pair) == W`Rule["a", 1]`

    # Test 9: Test with a more complex expression
    @variables a b
    expr = a^2 + b^2
    @test isequal(SymbolicsMathLink.wcall("Plus", a^2, b^2), expr)

    # Test 10: Test with nested expressions
    nested_expr = (a + b)^2
    @test isequal(SymbolicsMathLink.wcall("Power", a + b, 2), nested_expr)

    # Test 11: Test with an integral
    @variables t
    @test isequal(SymbolicsMathLink.wcall("Integrate", t^2, t), (1//3)*(t^3))

    # Test 12: Test with an equation
    @variables x
    expr = x^2 + 2x + 1
    result = wcall("Solve", expr~0)
    @test isequal(result, [[x => -1], [x => -1]])

    # Test 13: Test with a differential equation solution
    @variables u(t) C_1
    eq = Differential(t)(u) ~ u
    sol = SymbolicsMathLink.wcall("DSolve", eq, u, t)
    @test isequal(string(sol), string([[u => C_1 * Symbolics.exp(t)]]))

    # Test 14: Test inverse trig (cosecant) function
    @variables x
    @test SymbolicsMathLink.wcall(Val(false), "Csc", x, ) == W`Csc[x]`
    
    #Test 15: Test that expr_to_mathematica works properly
    @variables x y a b
    rules = [x => 1, y => 2, a => b]
    expr = x^2 + y^2 + a
    replaced = SymbolicsMathLink.wcall("ReplaceAll", expr, rules)
    @test isequal(replaced, 1^2 + 2^2 + b)
end