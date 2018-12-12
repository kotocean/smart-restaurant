local ingredients = {}

ingredients.inventory = {}

function ingredients:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function ingredients:add(ingre)
	table.insert(self.inventory, ingre)
end

function ingredients:add_group(ingres)
	for index, ingre in pairs(ingres) do
		self:add(ingre)
	end
end

function ingredients:get_first()
	return self.inventory[1]
end

function ingredients:remove(ingre)
	for k,v in pairs(self.inventory) do
		if v==ingre then
			table.remove(self.inventory, k)
			break
		end
	end
end

function ingredients:clear()
	for k,v in pairs(self.inventory) do
		table.remove(self.inventory, k)
	end
end

return ingredients

