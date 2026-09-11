using HTTP, Dates, LibGit2, JSON, OWLUpdate


function repo_add_file(user::NamedTuple, repo_name::String, filepath::String, content::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "git repository [$repo_name] doesn't exist"))
    end

    git_repo = LibGit2.GitRepo(realpath(repo.path))
    directory = dirname(filepath)
    filename = basename(filepath)

    # add directory
    mkpath(joinpath(repo.path, directory))
    dirpath = realpath(joinpath(repo.path, directory))
    git_add(git_repo, dirpath)

    # add .gitkeep
    keep_path = joinpath(dirpath, ".gitkeep")
    touch(keep_path)
    git_add(git_repo, keep_path)

    # add xml file
    owl_path = joinpath(dirpath, filename)
    open(owl_path, "w") do io
        write(io, content)
    end
    git_add(git_repo, owl_path)

    # load owl file.
    if contains(owl_path, ".xml")
        ctx = read_tbox_xml(owl_path)
    elseif contains(owl_path, ".toml")
        ctx = read_tbox_toml(owl_path)
    else
        throw(FatalError(message = "unknown owl path: $owl_path"))
    end
    analysis = calculate(ctx)

    # update metadata
    metadata_path = replace(owl_path, (".xml" => ".toml"))
    save_tbox_toml(analysis, metadata_path)
    git_add(git_repo, metadata_path)

    # commit signature
    sig = git_sig(user)
    message = "added $(git_path(git_repo, owl_path)) & $(git_path(git_repo, metadata_path)). by $(OWLUpdate.MODULE)"

    # commit
    commit_hash = git_commit(git_repo, sig, message)

    return (
        commit_hash = string(commit_hash),
        message = message,
        files = [
            ( name = git_path(git_repo, owl_path), ),
            ( name = git_path(git_repo, metadata_path), ),
        ],
        signature = string(sig),
    )
end

function repo_add_directory(user::NamedTuple, repo_name::String, filepath::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "git repository [$repo_name] doesn't exist"))
    end

    git_repo = LibGit2.GitRepo(realpath(repo.path))
    directory = dirname(filepath)

    # add directory
    mkpath(joinpath(repo.path, directory))
    dirpath = realpath(joinpath(repo.path, directory))
    git_add(git_repo, dirpath) 

    # add .gitkeep
    keep_path = joinpath(dirpath, ".gitkeep")
    touch(keep_path)
    git_add(git_repo, keep_path)

    # commit signature
    sig = git_sig(user)
    message = "added $(git_path(git_repo, dirpath)). by $(OWLUpdate.MODULE)"

    # commit
    commit_hash = git_commit(git_repo, sig, message)

    return (
        commit_hash = string(commit_hash),
        message = message,
        files = [
            ( name = directory, length = 0,)
        ],
        signature = string(sig),
    )
end


function repo_commit(user::NamedTuple, repo_name::String, filepath::String, message::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "git repository [$repo_name] doesn't exist"))
    end

    git_repo = LibGit2.GitRepo(realpath(repo.path))

    metadata_path = realpath(joinpath(repo.path, filepath * ".toml"))
    xml_path = realpath(joinpath(repo.path, filepath * ".xml"))
    ctx = read_tbox_toml(metadata_path)
    analysis = calculate(ctx)
    save_tbox_xml(analysis, xml_path)

    # add git file
    git_add(git_repo, xml_path)

    # commit signature
    sig = git_sig(user)
    message = message * " by $(OWLUpdate.MODULE)"

    # commit
    commit_hash = git_commit(git_repo, sig, message)

    return (
        commit_hash = string(commit_hash),
        message = message,
        signature = string(sig),
        repo = (
            id = repo.id,
            name = repo.name,
        ),
    )
end

function repo_reset(user::NamedTuple, repo_name::String, filepath::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "git repository [$repo_name] doesn't exist"))
    end

    run(`git -C $(repo.path) reset HEAD $(filepath).\*`)
    run(`git -C $(repo.path) restore $(filepath).\*`)

    git_repo = LibGit2.GitRepo(repo.path)

    head = LibGit2.GitCommit(git_repo, "HEAD")
    head_hash = LibGit2.GitHash(head)

    return (
        commit_hash = string(head_hash),
    )
end

function create_repo(user::NamedTuple, repo_name::String, description::String, remote_origin::String)
    repo = find_repository(user.id, repo_name)
    if repo != nothing
        throw(DBError(message = "$repo_name already exists in user:$user"))
    end

    git_path = joinpath(ENV["GIT_PATH"], user.name, repo_name)
    if contains(git_path, "..")
        throw(DomainError(message = "path = $git_path not allowed"))
    end

    # clear old repo
    rm(git_path, recursive=true, force=true)

    # create git repo
    mkpath(git_path)
    if isempty(remote_origin)
        git_repo = LibGit2.init(git_path)
    else
        git_repo = LibGit2.clone(remote_origin, git_path)
    end

    # register db
    repo = Repository(
        user_id = user.id,
        name = repo_name,
        path = git_path,
        remote_origin = remote_origin,
        description = description,
    )
    df = DataFrame([repo])
    db_insert(df, "repositories")

    return (
        repo = repo,
    )
end



