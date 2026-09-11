using OWLUpdate

function owl_load(user::NamedTuple, repo_name::String, filepath::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "git repository [$repo_name] doesn't exist"))
    end
    filepath = replace(filepath, (".xml" => ""))
    filepath = replace(filepath, (".toml" => ""))

    absolute_filepath = realpath(joinpath(repo.path, "$(filepath).toml"))
    @info absolute_filepath

    ctx = read_tbox_toml(absolute_filepath)
    analysis = calculate(ctx)
    return JSON.json(analysis)
end

function owl_load_shapley(user::NamedTuple, repo_name::String, filepath::String)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "git repository [$repo_name] doesn't exist"))
    end
    filepath = replace(filepath, (".xml" => ""))
    filepath = replace(filepath, (".toml" => ""))

    absolute_filepath = realpath(joinpath(repo.path, "$(filepath).toml"))

    ctx = read_tbox_toml(absolute_filepath)
    ctx = ShapleyContext(axioms = ctx.axioms)
    analysis = calculate(ctx)
    return JSON.json(analysis)
end

function owl_update(user::NamedTuple, repo_name::String, filepath::String, json::JSON.Object)
    repo = find_repository(user.id, repo_name)
    if repo == nothing
        throw(DBError(message = "git repository [$repo_name] doesn't exist"))
    end

    git_repo = LibGit2.GitRepo(realpath(repo.path))

    # update axioms
    ctx = read_tbox_json_axioms(json)
    analysis = calculate(ctx)

    # update metadata
    metadata_path = realpath(joinpath(repo.path, filepath * ".toml"))
    xml_path = realpath(joinpath(repo.path, filepath * ".xml"))
    save_tbox_toml(analysis, metadata_path)
    save_tbox_xml(analysis, xml_path)

    # add git file
    git_add(git_repo, metadata_path) 
    git_add(git_repo, xml_path) 

    return (
        message = "$(filepath) added to git staging.",
    )
end
