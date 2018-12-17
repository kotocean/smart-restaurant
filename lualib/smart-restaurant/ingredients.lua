local cjson = require("cjson")
local ingredients = {}


function read_share_inventory(index)
	local share_inventory = ngx.shared.share_inventory:get("inventory_" .. index)
	if not share_inventory then
		return nil
	else
		return cjson.decode(share_inventory)
	end
end

function write_share_inventory(index, inventory)
	ngx.shared.share_inventory:set("inventory_" .. index, cjson.encode(inventory))
end

function delete_share_inventory(index)
	ngx.shared.share_inventory:delete("inventory_" .. index)
end

function ingredients:new(o, index)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.index = index
	ngx.log(ngx.INFO, o.index)
	return o
end

function ingredients:set(ingres)
	write_share_inventory(self.index, ingres)
end


function ingredients:add_group(ingres)
	local inventory = read_share_inventory(self.index)
	if not inventory then
		write_share_inventory(self.index, ingres)
	else
		for i, ingre in pairs(ingres) do
			table.insert(inventory, ingre)
		end
		write_share_inventory(self.index, inventory)
	end
	ngx.log(ngx.INFO, "inventory:", cjson.encode(inventory))
end

function ingredients:delete()
	delete_share_inventory(self.index)
end

function ingredients:get()
	ngx.log(ngx.INFO, self.index)
	return read_share_inventory(self.index)
end

function ingredients:remove(ingre)
	local inventory = read_share_inventory(self.index)
	for k,v in pairs(inventory) do
		if type(v)=="table" and type(ingre)=="table" then
			if v.plate_num==ingre.plate_num then
				table.remove(inventory, k)
				break
			end 
		end
		if type(v)=="string" and type(ingre)=="string" then
			if v==ingre then
				table.remove(inventory, k)
				break
			end
		end
	end
	write_share_inventory(self.index, inventory)
end

function ingredients:remove_first()
	local inventory = read_share_inventory(self.index)
	if #inventory<=0 then
		return nil
	end
	local ingre = table.remove(inventory, 1)
	write_share_inventory(self.index, inventory)
	return ingre
end


return ingredients

