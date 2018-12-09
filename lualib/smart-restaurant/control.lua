local cjson = require("cjson")

local control = {}
control.watch_index = 0

function control:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function control:set_watch_index(index)
	self.watch_index = index
end

function control:to_transfer(plate_num)
	transfer_space = ngx.shared.share_transfer_space:get("transfer_space")
	plate_space = cjson.decode(transfer_space)
	plate_space[self.watch_index] = plate_num

	ngx.shared.share_transfer_space:set("transfer_space", cjson.encode(plate_space))
end

function control:from_transfer()
	transfer_space = ngx.shared.share_transfer_space:get("transfer_space")
	plate_space = cjson.decode(transfer_space)
	plate_num = plate_space[self.watch_index]
	plate_space[self.watch_index] = 0

	ngx.shared.share_transfer_space:set("transfer_space", cjson.encode(plate_space))
	return plate_num
end

return control