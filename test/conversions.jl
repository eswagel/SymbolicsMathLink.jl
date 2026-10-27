@testset "Conversions" begin
    @variables x y u(x)

    @testset "Symbolics 6 and 7 representations" begin
        # Exercise both Num wrappers and the underlying symbolic representation.
        # Symbolics 7 removed Symbolic, and its Num(::Complex) constructor must
        # not be overwritten by this package during precompilation.
        for expr in (x, x^2, sin(x), x + y, inv(x), Num(2), Num(1//3))
            expected = expr_to_mathematica(expr)
            @test expr_to_mathematica(Symbolics.unwrap(expr)) == expected
            @test isequal(mathematica_to_expr(expected), expr)
        end
        @test expr_to_mathematica(x) == W"x"
        @test expr_to_mathematica(x^2) == W"Power"(W"x", 2)
        @test expr_to_mathematica(sin(x)) == W"Sin"(W"x")
        @test expr_to_mathematica(inv(x)) == W"Divide"(1, W"x")
        @test expr_to_mathematica(x ~ y) == W"Equal"(W"x", W"y")
        @test isequal(mathematica_to_expr(W"Equal"(W"x", W"y")), x ~ y)
    end

    @testset "Containers and numeric helpers" begin
        @test expr_to_mathematica([x, y]) == W"List"(W"x", W"y")
        @test expr_to_mathematica([1 2 3; 4 5 6]) == W"List"(W"List"(1, 2, 3), W"List"(4, 5, 6))
        @test isequal(mathematica_to_expr(W"List"(W"List"(W"x", 2), W"List"(W"y", 3))), [[x, 2], [y, 3]])
        @test expr_to_mathematica(x => y) == W"Rule"(W"x", W"y")
        @test isequal(mathematica_to_expr(W"Rule"(W"x", W"y")), x => y)
        @test Dict(mathematica_to_expr(expr_to_mathematica(Dict(x => 1, y => 2)))) == Dict(x => 1, y => 2)
        @test expr_to_mathematica("text") == "text"
        @test mathematica_to_expr("text") == "text"
        @test expr_to_mathematica(2//3) == 2//3
        @test expr_to_mathematica(1 + 2im) == W"Complex"(1, 2)
        @test SymbolicsMathLink.numize_if_not_vector(1 + 2im) == Num(1) + Num(2)*im
        zero_imaginary = SymbolicsMathLink.numize_if_not_vector(Complex(1, 0))
        @test isequal(real(zero_imaginary), Num(1))
        @test isequal(imag(zero_imaginary), Num(0))
        nums = [Num(1), Num(2)]
        @test SymbolicsMathLink.numize_if_not_vector(nums) === nums
    end

    @testset "Arrays, functions, and derivatives" begin
        @variables arr[1:2, 1:3]
        for el in (arr[1, 2], arr[2, 3])
            @test Symbolics.toexpr(mathematica_to_expr(expr_to_mathematica(el))) == Symbolics.toexpr(el)
        end
        @test expr_to_mathematica(u) == W"u"(W"x")
        @test expr_to_mathematica(Differential(x)(u)) == W"D"(W"u"(W"x"), W"x")
        @test expr_to_mathematica((Differential(x)^2)(u)) == W"D"(W"D"(W"u"(W"x"), W"x"), W"x") ||
              expr_to_mathematica((Differential(x)^2)(u)) == W"D"(W"u"(W"x"), W"List"(W"x", 2))
        @test expr_to_mathematica(ifelse(x <= 0, -x, 0)) == W"Piecewise"(W"List"(W"List"(W"Times"(-1, W"x"), W"LessEqual"(W"x", 0))), 0)
        @test isequal(mathematica_to_expr(W"Piecewise"(W"List"(W"List"(W"Times"(-1, W"x"), W"LessEqual"(W"x", 0))), 0)), ifelse(x <= 0, -x, 0))
    end

end
