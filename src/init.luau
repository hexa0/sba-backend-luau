--!strict

local Players = game:GetService("Players")
local Requests = require("@self/requests")

local Authenticator = require("@self/authenticator")
local AuthenticatorType = require("@self/authenticatorType")

local playerAuth: {[number]: AuthenticatorType.Authenticator} = {}

Players.PlayerAdded:Connect(function(player)
	playerAuth[player.UserId] = Authenticator.new(player.UserId)
end)

Players.PlayerRemoving:Connect(function(player)
	playerAuth[player.UserId] = nil
end)

return {
	Requests = Requests;
	Authenticator = Authenticator;
	systemAuth = Authenticator.new(0);
	playerAuth = playerAuth;
}