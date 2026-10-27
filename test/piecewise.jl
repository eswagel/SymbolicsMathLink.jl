@testset "Piecewise branch order and defaults" begin
    @variables x
    branches = W"List"(
        W"List"(10, W"Less"(W"x", 0)),
        W"List"(20, W"Less"(W"x", 1)))
    two_branches = W"Piecewise"(branches, 30)
    three_branches = W"Piecewise"(
        W"List"(branches.args..., W"List"(30, W"Less"(W"x", 2))), 40)
    @test isequal(mathematica_to_expr(two_branches), ifelse(x < 0, 10, ifelse(x < 1, 20, 30)))
    @test isequal(mathematica_to_expr(three_branches), ifelse(x < 0, 10, ifelse(x < 1, 20, ifelse(x < 2, 30, 40))))
    @test isequal(mathematica_to_expr(W"Piecewise"(branches)), ifelse(x < 0, 10, ifelse(x < 1, 20, 0)))
    @test mathematica_to_expr(W"Piecewise"(W"List"(), 42)) == 42
    @test mathematica_to_expr(W"Piecewise"(W"List"())) == 0

    decoded = mathematica_to_expr(two_branches)
    evaluate = Symbolics.build_function(decoded, x; expression=Val(false))
    for (point, expected) in ((-1, 10), (0, 20), (2, 30))
        @test evaluate(point) == expected
    end
end
