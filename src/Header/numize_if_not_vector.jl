numize_if_not_vector(x::Vector{Num})=x
numize_if_not_vector(x::Vector)=numize_if_not_vector.(x)
numize_if_not_vector(x::Tuple)=[x...]
numize_if_not_vector(x::Num)=x
numize_if_not_vector(x)=Num(x)
numize_if_not_vector(x::Pair)=numize_if_not_vector(x[1]) => numize_if_not_vector(x[2])

Num(x::Complex)=Num(real(x))+Num(imag(x))*im