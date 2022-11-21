struct GamsParameter
    sets::Vector{GamsSet}
    value::DenseAxisArray
    description::String
    GamsParameter(s::GamsSet) = new([s],DenseAxisArray(zeros(length(s)),s))
end

