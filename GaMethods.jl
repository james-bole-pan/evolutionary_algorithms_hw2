module GaMethods

using .SymRegMethods

export crossover

function random_subexpr(expr, depth=0)
    if !isa(expr, Expr)
        return expr, depth
    end

    # Decide if we return this node or delve deeper
    if rand() < 0.2  # This probability can be adjusted
        return expr, depth
    end

    chosen_child = rand(expr.args[2:end])
    return random_subexpr(chosen_child, depth+1)
end

function replace_subexpr!(main_expr, old_subexpr, new_subexpr)
    if main_expr == old_subexpr
        return new_subexpr
    end

    for i in 1:length(main_expr.args)
        if main_expr.args[i] == old_subexpr
            main_expr.args[i] = new_subexpr
        elseif isa(main_expr.args[i], Expr)
            replace_subexpr!(main_expr.args[i], old_subexpr, new_subexpr)
        end
    end
    
    return main_expr
end

function crossover(parent1, parent2)
    subexpr1, _ = random_subexpr(deepcopy(parent1))
    subexpr2, _ = random_subexpr(deepcopy(parent2))

    child1 = replace_subexpr!(deepcopy(parent1), subexpr1, subexpr2)
    child2 = replace_subexpr!(deepcopy(parent2), subexpr2, subexpr1)

    return child1, child2
end

# # Example Usage:
# expr1 = random_expression(3)
# expr2 = random_expression(3)
# println("parents: ", expr1, " and ", expr2)
# child1, child2 = crossover(expr1, expr2)
# println("children: ", child1, " and ", child2)
end