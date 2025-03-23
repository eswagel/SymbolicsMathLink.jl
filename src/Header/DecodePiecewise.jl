#Turn a piecewise function from MathLink into a ifelse function
function decode_piecewise(lists::Vector{Vector{Num}}, lastval)
    @nospecialize
    second_to_lastval::Vector = lists[end]
    ret = ifelse(second_to_lastval[2], second_to_lastval[1], lastval)
    for i=length(lists)-2:-1:1
        cur_val::Vector = lists[i]
        ret = ifelse(curval[2], curval[1], ret)
    end
    ret
end
function decode_piecewise(lists::Vector{Num}, lastval)
    @nospecialize
    ifelse(lists[2], lists[1], lastval)
end
function decode_piecewise(lists::Vector{Vector})
    @nospecialize
    ret = ifelse(lists[1][2], lists[1][1], nothing)
    for i=2:length(lists)
        ret = ifelse(lists[i][2], lists[i][1], ret)
    end
    ret
end
