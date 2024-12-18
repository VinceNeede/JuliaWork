function add!(C::WArray, A::WArray, B::WArray)
    @assert size(C) == size(A) == size(B)
    @inbounds for i in 1:length(C)
        C[i] = A[i] + B[i]
    end
end
function add(A::WArray, B::WArray)
    C = similar(A)
    add!(C, A, B)
    return C
end
Base.:+(A::WArray, B::WArray) = add(A, B)