using SymbolicsMathLink
using Test

@testset "SymbolicsMathLink.jl" begin
    @test SymbolicsMathLink.wcall("Part",[1,2],2)==2
end
