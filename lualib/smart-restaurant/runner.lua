local cjson = require("cjson")

local runner = {}

function runner:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function transfer(premature)
	share_transfer_space = ngx.shared.share_transfer_space
	transfer_space = share_transfer_space:get("transfer_space")
	space_list = cjson.decode(transfer_space)
	temp_list = {}
	for i=2, table.maxn(space_list) do
		table.insert(temp_list, space_list[i])
	end
	table.insert(temp_list, space_list[1])
	share_transfer_space:set("transfer_space", cjson.encode(temp_list))
	ngx.log(ngx.INFO, "转圈 ","====>>>>", cjson.encode(temp_list))
end

function init_plate_space(total)
	local arr = {}
	for i = 1, total do
	  table.insert(arr, 0)
	end
	return arr
end

function runner:run(total)
	-- 初始化20个空的盘空间
	plate_space = init_plate_space(total)
	ngx.log(ngx.INFO, cjson.encode(plate_space))
	ngx.shared.share_transfer_space:set("transfer_space", cjson.encode(plate_space))

	hdl, err = ngx.timer.every(5, transfer)
end

return runner