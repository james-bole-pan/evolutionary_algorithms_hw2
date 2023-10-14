using AbstractTrees
using .SymRegMethods

expr = :(x*x+10)

const PROBABILITY_MUTATION = 0.9
const PROBABILITY_IN_PLACE_MUTATION = 0.9 # in-place mutation vs. new subtree
const PROBABILITY_SYMBOL_MUTATION = 0.5 # symbol vs. constant

function mutate(expr)
    expr = deepcopy(expr)
    if rand() < (1 - PROBABILITY_MUTATION) # probability of not mutating
        return expr
    else
        if rand() < PROBABILITY_IN_PLACE_MUTATION # assign higher probability to "new number/terminal"
            if isa(expr, Expr)
                op = rand(FUNCTIONS)
                if op in [:sin, :cos]
                    return Expr(:call, op, mutate(expr.args[2]))
                else
                    if length(expr.args) == 2
                        return Expr(:call, op, mutate(expr.args[2]), random_expression(1))
                    else
                        return Expr(:call, op, mutate(expr.args[2]), mutate(expr.args[3]))
                    end
                end
            else  
                if rand() < PROBABILITY_SYMBOL_MUTATION
                    return rand(TERMINALS)
                else
                    return random_constant()
                end
            end
        else # new subtree
            return random_expression(2)
        end
    end
end

println(expr)
println(mutate(expr))