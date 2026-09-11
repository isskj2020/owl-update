using DataFrames, Random, Dates


@kwdef struct Repository
    id::String = randstring(32)
    user_id::String
    name::String
    path::String
    remote_origin::String
    description::String
    updated_at::DateTime = now()
end


function Repository(row::DataFrameRow)
    return Repository(
        id = row.id,
        user_id = row.user_id,
        name = row.name,
        path = row.path,
        remote_origin = row.remote_origin,
        description = row.description,
        updated_at = row.updated_at
    )
end


function find_repository(user_id::String, repo_name::String)
    sql = """
    SELECT id, name, path, description, remote_origin FROM repositories WHERE user_id = ? AND name = ?
    """
    df = DataFrame(db_fetch(sql, [user_id, repo_name]))
    if isempty(df)
        return nothing
    end
    return first(df)
end
