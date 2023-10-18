using AbstractTrees

function AbstractTrees.printnode(io::IO, x::Expr)
    if x.head == :call
        print(io, x.args[1])
    else
        print(io, x)
    end
end

function AbstractTrees.children(x::Expr)
    if x.head == :call
        return x.args[2:end]
    else
        return x.args
    end
end

expr = :((x*x-x)+(-6.561x))
println("Best expression:", expr)
print_tree(expr)