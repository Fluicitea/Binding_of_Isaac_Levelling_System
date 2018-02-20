local bitmapConverter = {}

function bitmapConverter.BitmapConvert(decimal)
	local bitmap = decimal
	n = 0
	while bitmap > 0 do
		bitmap = bitmap - 2^(math.floor(math.log(bitmap) / math.log(2)))
		n = n + 1
	end
	return n
end

return bitmapConverter