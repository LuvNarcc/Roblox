local TextChatService = game:GetService("TextChatService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

TextChatService.OnIncomingMessage = function(Message: TextChatMessage)
	local Properties = Instance.new("TextChatMessageProperties")

	if Message.TextSource then
		local UserID = Message.TextSource.UserId
		local Success, Owns = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(UserID, 1576515732)
		end)

		local PlayerName = Players:GetNameFromUserIdAsync(UserID)

		if Success and Owns then
			--// Grant the [VIP] Prefix and change the username and prefix color to gold 
			Properties.PrefixText = string.format(
				"<font color='rgb(255,193,107)'>[VIP] %s:</font>",
				PlayerName
			)
		else
			--// If they dont have the gamepass make their name grey 
			Properties.PrefixText = string.format(
				"<font color='rgb(128,128,128)'>%s:</font>",
				PlayerName
			)
		end
	end

	return Properties
end
