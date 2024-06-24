return {
    calc = function(item, count)
        local recipe = Data.recipes[item]
        if not recipe then
            return false
        end

        local ingredients = recipe.ingredients
        for ingredient, amount in pairs(ingredients) do
            if not self:has_item(ingredient, amount * count) then
                return false
            end
        end

        for ingredient, amount in pairs(ingredients) do
            self:remove_item(ingredient, amount * count)
        end

        self:add_item(item, count)
        return true
    end,
}
