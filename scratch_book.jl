using AbstractTrees
using .SymRegMethods

function AbstractTrees.children(ex)
    if ex.head == :call
        return ex.args[2:end]  # Skip the function symbol and return only the arguments
    else
        return []
    end
end

AbstractTrees.children(s) = []

expr = random_expression(2)
println("Expression: $expr")
println(expr.head)
println(expr.args)
print_tree(expr)


