local cjson = require("cjson")

local runner = {}

function runner:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function read_share_transfer_space()
	local share_transfer_space = ngx.shared.share_transfer_space:get("share_transfer_space")
	return cjson.decode(share_transfer_space)
end

function write_share_transfer_space(share_transfer_space)
	ngx.shared.share_transfer_space:set("share_transfer_space", cjson.encode(share_transfer_space))
end

function runner:set(index, value)
	local share_transfer_space = read_share_transfer_space()
	share_transfer_space[tonumber(index)] = value
	write_share_transfer_space(share_transfer_space)
end

function runner:get(index)
	return read_share_transfer_space()[tonumber(index)]
end

function runner:status()
	return read_share_transfer_space()
end

function transfer(premature)
	local transfer_space = cjson.decode(ngx.shared.share_transfer_space:get("share_transfer_space"))
	local first = table.remove(transfer_space, 1)
	table.insert(transfer_space, first)
	ngx.shared.share_transfer_space:set("share_transfer_space", cjson.encode(transfer_space))
	ngx.log(ngx.INFO, "转圈 ","====>>>>", cjson.encode(transfer_space))
end

function init_plate_space(total)
	local arr = {}
	for i = 1, total do
	  table.insert(arr, "")
	end
	return arr
end

function runner:run(total)
	-- 初始化20个空的盘空间
	local share_transfer_space = init_plate_space(total)
	write_share_transfer_space(share_transfer_space)

	hdl, err = ngx.timer.every(5, transfer)
end
return runner