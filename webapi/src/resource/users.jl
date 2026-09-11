using DataFrames, Random, Dates


@kwdef struct User
    id::String = randstring(32)
    role::String = ""
    name::String = ""
    email::String = ""
    password_hash::String = ""
    updated_at::DateTime = now()
end


function User(row::DataFrameRow)
    return User(
        id = row.id,
        role = row.role,
        name = row.name,
        email = row.email,
        password_hash = row.password_hash,
        updated_at = row.updated_at
    )
end

