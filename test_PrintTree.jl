using AbstractTrees
using .SymRegMethods

expr = Expr(:call, :+, 1, Expr(:call, :*, :x, 3))

function mutate(expr)
    if rand() < 0.2 # probability of not mutating
        return expr
    else
        mutation_type = rand(["new number/terminal", "new subtree"])
        if mutation_type == "new number/terminal"
            if isa(expr, Expr)
                op = rand(FUNCTIONS)
                if op in [:sin, :cos]
                    return Expr(:call, op, expr.args[2])
                else
                    return Expr(:call, op, expr.args[2], expr.args[3])
                end
            else
                if rand() < 0.5 # probability of replacing a float/symbol with a symbol
                    return rand(TERMINALS)
                else
                    return random_constant()
                end
            end
        else # new subtree
            return random_expression(2)
        end
    end
            
    for i in 1:length(expr.args)
        expr.args[i] = mutate(expr.args[i])
    end
end

expr = :(x + 1)
println(expr)
println(mutate(expr))