# Mathematica uses the first matching branch and defaults to zero.
function decode_piecewise(lists::AbstractVector, lastval=0)
    @nospecialize
    ret = lastval
    for branch in Iterators.reverse(lists)
        ret = ifelse(branch[2], branch[1], ret)
    end
    ret
end
