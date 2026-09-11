

function transform_tbox_file(filepath::String)
    segments = splitext(filepath)
    if segments[2] === ".toml"
        ctx = read_tbox_toml(filepath)
    elseif segments[2] === ".xml"
        ctx = read_tbox_xml(filepath)
    else
        throw(DomainError(filepath, "invalid file type"))
    end
    analysis = calculate(ctx)
    toml_file = "$(segments[1]).toml"
    xml_file = "$(segments[1]).xml"
    save_tbox_toml(analysis, toml_file)
    @info "saved tbox toml: $toml_file"
    save_tbox_xml(analysis, xml_file)
    @info "saved tbox xml: $xml_file"

    violated_nodes = use_hermiT(xml_file)
    @info "violated node:$violated_nodes"
end

function transform_tbox_bulk_files(dir::String)
    for file in readdir(dir)
        segments = splitext(file)
        if segments[2] === ".xml"
            transform_tbox_file(realpath(joinpath(dir, file)))
        end
    end
end
