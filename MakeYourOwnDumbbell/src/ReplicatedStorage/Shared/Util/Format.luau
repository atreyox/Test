--[[
	Format - turns numbers into short, readable text.

	Format.Short(1234)        -> "1.23K"
	Format.Short(5.2e15)      -> "5.2Qa"
	Format.Commas(1234567)    -> "1,234,567"
	Format.Time(125)          -> "2m 05s"
	Format.Percent(0.125)     -> "12.5%"
	Format.Mult(2.5)          -> "x2.5"
]]

local Format = {}

local SUFFIXES = {
	"", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc",
	"Ud", "Dd", "Td", "Qad", "Qid", "Sxd", "Spd", "Ocd", "Nod", "Vg",
	"Uvg", "Dvg", "Tvg", "Qavg", "Qivg", "Sxvg", "Spvg", "Ocvg", "Novg", "Tg",
}

local function trim(s: string): string
	-- "1.50" -> "1.5", "2.00" -> "2"
	if string.find(s, "%.") then
		s = string.gsub(s, "0+$", "")
		s = string.gsub(s, "%.$", "")
	end
	return s
end

-- Short form with ~3 significant digits.
function Format.Short(n: number?): string
	n = n or 0
	if n ~= n then
		return "0"
	end
	if n == math.huge then
		return "∞"
	end
	local negative = n < 0
	n = math.abs(n)
	local text: string
	if n < 1000 then
		if n < 10 and n ~= math.floor(n) then
			text = trim(string.format("%.1f", math.floor(n * 10) / 10))
		else
			text = tostring(math.floor(n))
		end
	else
		local tier = math.floor(math.log10(n) / 3)
		tier = math.min(tier, #SUFFIXES - 1)
		local scaled = n / 10 ^ (tier * 3)
		-- floor instead of round so 999.9K never shows as 1000K
		if scaled >= 100 then
			text = tostring(math.floor(scaled))
		elseif scaled >= 10 then
			text = trim(string.format("%.1f", math.floor(scaled * 10) / 10))
		else
			text = trim(string.format("%.2f", math.floor(scaled * 100) / 100))
		end
		text ..= SUFFIXES[tier + 1]
	end
	return (negative and "-" or "") .. text
end

function Format.Commas(n: number?): string
	n = math.floor(n or 0)
	if math.abs(n) >= 1e15 then
		return Format.Short(n)
	end
	local s = tostring(math.abs(n))
	local out = string.reverse((string.gsub(string.reverse(s), "(%d%d%d)", "%1,")))
	out = string.gsub(out, "^,", "")
	return (n < 0 and "-" or "") .. out
end

function Format.Time(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	local h = math.floor(seconds / 3600)
	local m = math.floor((seconds % 3600) / 60)
	local s = seconds % 60
	if h > 0 then
		return string.format("%dh %02dm", h, m)
	elseif m > 0 then
		return string.format("%dm %02ds", m, s)
	end
	return string.format("%ds", s)
end

function Format.Clock(seconds: number): string
	seconds = math.max(0, math.floor(seconds))
	return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

function Format.Percent(fraction: number, decimals: number?): string
	local d = decimals or 1
	return trim(string.format("%." .. d .. "f", fraction * 100)) .. "%"
end

function Format.Mult(m: number): string
	if m >= 1000 then
		return "x" .. Format.Short(m)
	end
	return "x" .. trim(string.format("%.2f", m))
end

function Format.Chance(p: number): string
	-- 0.004 -> "1 in 250"
	if p <= 0 then
		return "—"
	end
	if p >= 0.1 then
		return Format.Percent(p)
	end
	return "1 in " .. Format.Short(math.floor(1 / p + 0.5))
end

function Format.Weight(kg: number): string
	return Format.Short(kg) .. " kg"
end

return Format
