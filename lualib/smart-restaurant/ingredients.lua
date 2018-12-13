local cjson = require("cjson")
local ingredients = {}


function read_share_transfer_space(index)
	local share_transfer_space = ngx.shared.share_transfer_space:get("inventory" .. index)
	return cjson.decode(share_transfer_space)
end

function write_share_transfer_space(index, inventory)
	ngx.shared.share_transfer_space:set("inventory" .. index, cjson.encode(inventory))
end

function ingredients:new(o, index)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.index = index
	return o
end

function ingredients:set(ingres)
	write_share_transfer_space(self.index, ingres)
end

function ingredients:get()
	return read_share_transfer_space(self.index)
end

function ingredients:remove(ingre)
	local inventory = read_share_transfer_space(self.index)
	for k,v in pairs(inventory) do
		if v==ingre then
			table.remove(inventory, k)
			break
		end
	end
	write_share_transfer_space(self.index, inventory)
end


return ingredients

