const Str = String

# the code in this file is meant to serve as a programming exercise only
# it may not act correctly

# count must contain "nDirs" => 0 and "nFiles" => 0
function printCatalogTree!(path::Str, pad::Str,
                           count::Dict{Str, Int})::Nothing
    @assert haskey(count, "nDirs") "count must have a key nDirs"
    @assert haskey(count, "nFiles") "count must have a key nFiles"
    newPad::Str = pad * "--- "
    for name in readdir(path)
        newPath::Str = joinpath(path, name)
        if isfile(newPath)
            println(newPad, name)
            count["nFiles"] += 1
        else
            println(newPad, name, "/")
            count["nDirs"] += 1
            printCatalogTree!(newPath, pad * "    |", count)
        end
    end
    return nothing
end

function printCatalogTree(path::Str)::Nothing
    if !isdir(path)
        println("The path $path/ does not exist.")
        return nothing
    end
    println(path, "/")
    count::Dict{Str, Int}= Dict("nDirs" => 0, "nFiles" => 0)
    printCatalogTree!(path, "|", count)
    print("\n", count["nDirs"], " directories, ", count["nFiles"], " files")
    return nothing
end

# make sure to create the catalogs (with their contents) first
printCatalogTree(joinpath(homedir(), "Desktop", "catalog_x"))
printCatalogTree(joinpath(homedir(), "Desktop", "catalog_a"))
printCatalogTree(joinpath(homedir(), "Desktop", "catalog_zzz"))
