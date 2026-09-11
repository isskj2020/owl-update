using HTTP, Dates, LibGit2

function fetch_repos(user::NamedTuple)
    sql = """
    SELECT * FROM repositories WHERE user_id = ?
    """
    data = db_fetch(sql, [user.id])
    res = NamedTuple.(eachrow(data))
    return ( repos = res,)
end

function delete_repo(repo_name::String)
    sql = """
    DELETE FROM repositories WHERE name = ?
    """
    db_exec(sql, [repo_name])
end

function fetch_repo_files(user::NamedTuple, repo_name::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "repository $repo_name doesn't exists in user:$user"))
    end

    try
        files = read(`git -C $(repo.path) ls-files`, String) |>
        x -> split(x, "\n") |>
        x -> filter(y -> !isempty(y), x)

        res_files = Vector()
        for f in files
            path = joinpath(repo.path, f)
            status = stat(path)
            push!(res_files, (
                isfile = isfile(path),
                canload = contains(f, ".xml") || contains(f, ".toml"),
                name = f,
                updated = unix2datetime(status.mtime),
                size = filesize(path)
            ))
        end
        sort!(res_files, by = f -> f.name)
        return ( files = res_files, )
    catch e
        delete_repo(repo_name)
        rethrow(e)
    end
end

function fetch_repo_status(user::NamedTuple, repo_name::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "repository $repo_name doesn't exists in user:$user"))
    end

    status = read(`git -C $(repo.path) status`, String)
    return (
        status = status,
    )
end


function fetch_repo_logs(user::NamedTuple, repo_name::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "repository $repo_name doesn't exists in user:$user"))
    end

    git_repo = LibGit2.GitRepo(repo.path)

    walker = LibGit2.GitRevWalker(git_repo)

    LibGit2.push!(walker, LibGit2.head_oid(git_repo))

    logs = Vector()
    for oid in walker
        c = LibGit2.GitCommit(git_repo, oid)
        push!(logs, git_log_item(c))
    end
    return (
        logs = logs,
    )
end

function fetch_repo_diffs(user::NamedTuple, repo_name::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "git repository [$repo_name] doesn't exist"))
    end

    text = read(`git -C $(repo.path) diff -U8 --text HEAD`, String)
    return (
        text = text,
    )
end
