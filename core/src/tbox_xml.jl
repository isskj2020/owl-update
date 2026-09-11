using XML, OrderedCollections

find_nodes(node, name) = [c for c in children(node) if tag(c) == name]

function read_tbox_xml(
        filepath::String;
        decay_factor = K_DEFAULT_DECAY_FACTOR,
    )
    constraints = Vector{Constraint}()
    namespaces = OrderedDict{String, String}()

    doc = read(filepath, LazyNode)

    for node in children(doc)
        tag(node) == "rdf:RDF" || continue

        for attr in attributes(node)
            key = String(attr.first)
            key == "xmlns" && continue
            namespaces[key] = attr.second
        end

        classes = Vector{String}()
        for class in find_nodes(node, "owl:Class")
            about = find_attrs(class, "rdf:about")
            about === nothing && continue
            sub = replace_xmlns(namespaces, about)
            sub === nothing && continue

            for subclass in find_nodes(class, "rdfs:subClassOf")
                resource = find_attrs(subclass, "rdf:resource")
                resource === nothing && continue
                obj = replace_xmlns(namespaces, resource)
                c = SubClassOf(subject = sub, parent = obj)
                c.id = "$c"
                push!(constraints, c)
            end

            for disjoint in find_nodes(class, "owl:disjointWith")
                resource = find_attrs(disjoint, "rdf:resource")
                resource === nothing && continue
                obj = replace_xmlns(namespaces, resource)
                c = DisjointWith(subject = sub, object = obj)
                c.id = "$c"
                push!(constraints, c)
            end
        end
    end

    unique!(constraints)
    sort!(namespaces)
    sort!(constraints; by = constraint_sort_key)

    constraints = append_tbox_root(constraints)
    axioms = OWLAxioms(constraints, namespaces, decay_factor)
    context = TBoxContext(axioms = axioms)
    prepare!(context)
    return context
end

function save_tbox_xml(analysis::OWLAnalysis, filepath::String)
    doc = XML.Document()
    push!(doc, XML.Declaration(version = "1.0",encoding = "UTF-8"))

    namespaces = analysis.namespaces
    constraints = map(x -> x.constraint, analysis.results)

    attrs = Dict(Symbol(k) => v for (k, v) in namespaces)
    rdf = XML.Element("rdf:RDF"; attrs...)

    for c in constraints
        if c isa SubClassOf
            subject = convert_domain_name(c.subject, namespaces)
            parent = convert_domain_name(c.parent, namespaces)
            attrs = Dict(Symbol("rdf:about") => subject)
            owl_class = XML.Element("owl:Class"; attrs...)
            attrs = Dict(Symbol("rdf:resource") => parent)
            owl_subclass = XML.Element("rdfs:subClassOf"; attrs...)
            push!(owl_class, owl_subclass)
            push!(rdf, owl_class)
        elseif c isa DisjointWith
            subject = convert_domain_name(c.subject, namespaces)
            object = convert_domain_name(c.object, namespaces)
            attrs = Dict(Symbol("rdf:about") => subject)
            owl_class = XML.Element("owl:Class"; attrs...)
            attrs = Dict(Symbol("rdf:resource") => object)
            owl_disjoint_with = XML.Element("owl:disjointWith"; attrs...)
            push!(owl_class, owl_disjoint_with)
            push!(rdf, owl_class)
        end
    end
    push!(doc, rdf)
    XML.write(filepath, doc)
end

function replace_xmlns(dict, node)
    len = -1
    key = nothing
    node === nothing && return nothing
    for (k, v) in dict
        occursin(v, node) || continue
        l = length(v)
        if l > len
            len = l
            key = k
        end
    end
    if key === nothing
        return node
    end
    ns_tag = replace(key, r"^xmlns:" => "")
    return replace(node, dict[key] => "$ns_tag:")
end

function convert_domain_name(name::String, namespaces::Dict{String,String})
    names = split(name, ":")
    if length(names) == 2
        key = "xmlns:$(names[1])"
        return namespaces[key] * names[2]
    end
    return name
end

function find_attrs(node, key::String)
    attrs = attributes(node)
    attrs === nothing && return nothing
    for attr in attributes(node)
        if attr.first == key
            return attr.second
        end
    end
    return nothing
end

