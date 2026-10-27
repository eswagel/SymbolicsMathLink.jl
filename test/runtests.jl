using SymbolicsMathLink
using Symbolics
using MathLink
using Test

include("conversions.jl")
include("piecewise.jl")

# The default test run includes real Wolfram calls. CI can exercise the
# converters without a Wolfram license by explicitly selecting this mode.
if get(ENV, "SYMBOLICSMATHLINK_TEST_MODE", "full") == "conversions"
    @info "Running conversion tests only; Wolfram integration tests were not requested"
else
    include("integration.jl")
end
