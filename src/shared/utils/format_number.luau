--// Constants
const SUFFIXES = { "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

--// Functions
const function commas_format(number: number)
	local formatted = string.format("%.2f", number)

	while true do
		const result, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = result

		if count ~= 0 then continue end
		break
	end

	formatted = string.gsub(formatted, "%.00$", "")
	return formatted
end

--// End
return function(number: number, cases: number?)
	if number < 1e3 then return commas_format(number) end

	const magnitude = math.floor(math.log10(number) / 3)
	const suffix_index = math.min(magnitude, #SUFFIXES)

	const divisor = 10 ^ (magnitude * 3)
	const short_number = number / divisor
	local formatted = string.format(`%.{cases or 2}f`, short_number)

	formatted = string.gsub(formatted, "%.?0+$", "")
	return formatted .. SUFFIXES[suffix_index]
end
