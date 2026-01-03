--!strict

local Requests = require("@self/requests")
local Authenticator = require("@self/authenticator")

return {
	Requests = Requests;
	Authenticator = Authenticator;
	systemAuth = Authenticator.new(0);
}