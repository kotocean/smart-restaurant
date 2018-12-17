local cjson = require("cjson")

local control = {}

function control:new(o, watch_index)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.watch_index = watch_index
	return o
end

function read_share_transfer_space()
	local share_transfer_space = ngx.shared.share_transfer_space:get("share_transfer_space")
	return cjson.decode(share_transfer_space)
end

function write_share_transfer_space(share_transfer_space)
	ngx.shared.share_transfer_space:set("share_transfer_space", cjson.encode(share_transfer_space))
end

function control:to_transfer(plate_num)
	local transfer_space = read_share_transfer_space()
	transfer_space[self.watch_index] = plate_num

	write_share_transfer_space(transfer_space)
end

function control:from_transfer()
	local transfer_space = read_share_transfer_space()
	local plate_num = transfer_space[self.watch_index]
	transfer_space[self.watch_index] = ""

	write_share_transfer_space(transfer_space)
	return plate_num
end

return control