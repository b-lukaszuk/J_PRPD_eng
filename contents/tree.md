# Tree {#sec:tree}

In this chapter I did not use any external libraries. Still, once you read the
problem description you may decide to do otherwise. In that case don't let me
stop you.

I recommend you try to solve the task on your own first. Once you finish you may
compare your solution with the one in this chapter (with explanations) or with
[the code
snippets](https://github.com/b-lukaszuk/J_PRPD_eng/tree/main/code_snippets/tree)
(without explanations).

A reminder of how to deal with packages and \*.toml files can be found
[here](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Problem {#sec:tree_problem}

There is this nice little command
[tree](https://en.wikipedia.org/wiki/Tree_(command)) that recursively lists
files and sub-directories in a given location. Let's try to get some of that
with Julia.

Write a function `printCatalogTree` that displays the contents of a given
directory like so (the output doesn't have to be exact):

```
~/Desktop/catalog_x/
|--- catalog_y/
|    |--- catalog_z/
|    |    |--- file_z.txt
|    |--- file_y.txt
|--- file_x.txt

2 directories, 3 files
```

Here, we got three nested catalogs: x, y, and z. Each contains a file of a
corresponding name inside of it.

Hint: If you are stuck now, start by reading about Julia's
[Filesystem](https://docs.julialang.org/en/v1/base/file/).

## Solution {#sec:tree_solution}

Let's start small with an initial definition of `printCatalogTree`.

```
function printCatalogTree(path::Str, pad::Str)::Nothing
    newPad::Str = pad * "    "
    for name in readdir(path)
        newPath::Str = joinpath(path, name)
        if isfile(newPath)
            println(newPad, name)
        else
            println(newPad, name, "/")
            printCatalogTree(newPath, newPad)
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
    printCatalogTree(path, "")
    return nothing
end
```

The function is rather simple. We walk through every entry (`for name`) in the
examined directory (`path`). As we go `name` is converted to `newPath` which
will be examined in a moment. If `newPath` is a file (`isfile`) we just print
it, otherwise (`else`) it is a directory and we print it with `"/"` to make it
stand out. Moreover, we go inside of it with `printCatalogTree` (recursive call)
to print its contents. For every nesting of `printCatalogTree` we update the
padding `newPad` by increasing the indentation with `* " "`.

We conclude with another version of `printCatalogTree`. The method will make the
function's invocation slightly easier (it requires only one argument so the user
does not have to think what the `pad` should be). Moreover, it handles the
possibility that the `path` may not exist (`if !isdir(path)`). Additionally, it
will add a header line for us (`println(path, "/")`) in order to display the
root directory.

Let's see how it works (remember to create `catalog_x` with its contents first).

```
printCatalogTree(joinpath(homedir(), "Desktop", "catalog_x"))
```

```
/home/user_name/Desktop/catalog_x/
    catalog_y/
        catalog_z/
            file_z.txt
        file_y.txt
    file_x.txt
```

It looks quite alright. Time to replace the spaces on the left with some
guideways that we may follow with our eyes.

```
function printCatalogTree(path::Str, pad::Str)::Nothing
    newPad::Str = pad * "--- "
    for name in readdir(path)
        newPath::Str = joinpath(path, name)
        if isfile(newPath)
            println(newPad, name)
        else
            println(newPad, name, "/")
            printCatalogTree(newPath, pad * "    |")
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
    printCatalogTree(path, "|")
    return nothing
end
```

To that end we changed the `pad`s. We begin with the first column on the left
that should start with the pipe character (`printCatalogTree(path, "|")`). Each
line containing a file or directory should continue with hyphens
(`newPad::Str = pad * "---"`), whereas a nested directory and its contents
should be indented and start with the pipe character as well
(`printCatalogTree(newPath, pad * " |")`). Let's see does it work as intended.

```
printCatalogTree(joinpath(homedir(), "Desktop", "catalog_x"))
```

```
/home/user_name/Desktop/catalog_x/
|--- catalog_y/
|    |--- catalog_z/
|    |    |--- file_z.txt
|    |--- file_y.txt
|--- file_x.txt
```

Not bad at all. Time to add a summary line.

```
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
```

The necessary data will be collected in a dictionary (`count`). It has two keys:
`nDirs` and `nFiles` for the number of directories and files in the tree,
respectively. Remember that in Julia dictionaries are passed by reference so any
modification you make to them inside of a function will be visible outside.
For that purpose `count` is defined in the outer `printCatalogTree`, whereas the
inner `printCatalogTree!` got exclamation point per Julia's convention to mark a
function that modifies its arguments. Anyway, the `count` dictionary is updated
for every file (`count["nFiles"] += 1`) and directory (`count["nDirs"] += 1`)
encountered and a summary line is added at the very bottom of the output
(`print("\n", count["nDirs"], " directories, ", count["nFiles"], " files")`).
Let's see how it works on a few examples (feel free to recreate mock directory
structures as seen here).

First, a simple, already familiar to us, case.

```
printCatalogTree(joinpath(homedir(), "Desktop", "catalog_x"))
```

```
/home/user_name/Desktop/catalog_x/
|--- catalog_y/
|    |--- catalog_z/
|    |    |--- file_z.txt
|    |--- file_y.txt
|--- file_x.txt

2 directories, 3 files
```

Now, a bit more convoluted tree.

```
printCatalogTree(joinpath(homedir(), "Desktop", "catalog_a"))
```

```
/home/user_name/Desktop/catalog_a/
|--- catalog_b/
|    |--- catalog_d/
|    |    |--- file_d.txt
|    |--- file_b1.txt
|    |--- file_b2.txt
|--- catalog_c/
|    |--- catalog_e/
|    |    |--- file_e.txt
|    |--- catalog_f/
|    |    |--- file_f1.txt
|    |    |--- file_f2.txt
|    |    |--- file_f3.txt
|    |    |--- file_f4.txt
|--- file_a.txt

5 directories, 9 files
```

And an empty directory.

```
printCatalogTree(joinpath(homedir(), "Desktop", "catalog_zzz"))
```

```
/home/user_name/Desktop/catalog_zzz/

0 directories, 0 files
```

OK, that's it. Another tiny utility under our belts.
