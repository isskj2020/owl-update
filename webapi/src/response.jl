@kwdef mutable struct Response
    status::Int
    headers::Dict{String,String} = Dict()
    body::Any
end

