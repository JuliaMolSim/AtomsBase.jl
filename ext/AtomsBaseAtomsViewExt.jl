module AtomsBaseAtomsViewExt
    using AtomsBase
    using AtomsView

    function Base.show(io::IO, mime::MIME"text/html", system::AbstractSystem)
        write(io, AtomsView.visualize_structure(system, mime))
    end
end
