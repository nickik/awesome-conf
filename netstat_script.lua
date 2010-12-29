require("cURL")


function iss (IP_range)
	local IP
	
	c = cURL.easy_init()
	c:setopt_url("www.icanhazip.com")
	c:perform({writefunction = function(str)
					 IP = str
				     end})

	if string.find(IP, IP_range) then
		return "VPN " ..  IP
	else
		if IP then
			return "Internet " .. IP
		else
			return "Offline"
		end
	end
end

print( iss("80.190"))

