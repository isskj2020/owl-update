abstract type ApiError end

@kwdef struct AuthError <: ApiError
    status::Int=401
    message::String
end

@kwdef struct DBError <: ApiError
    status::Int=401
    message::String
end

@kwdef struct FatalError <: ApiError
    status::Int=500
    message::String
end

