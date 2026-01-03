--!strict

local HttpService = game:GetService("HttpService")

local AuthenticatorType = require("./authenticatorType")
type Authenticator = AuthenticatorType.Authenticator

local Config = require("./config")
local Http = require("./http")

local Authenticator: Authenticator = {} :: any
Authenticator.__index = Authenticator

local AUTH_SECRET = HttpService:GetSecret(Config.BACKEND_AUTH_SECRET_KEY)
-- server side tokens will expire after 1h, here we assume it expires 1 minute before
local EXPIRY_TIME = 60 * 59

function Authenticator:IsExpired()
	return tick() - self._lastIssued > EXPIRY_TIME
end

function Authenticator:GetToken(): string
	if self._token and not self:IsExpired() then
		return self._token
	else
		local response = Http.AuthHandshake(
			AUTH_SECRET,
			self._userId
		)

		self._token = response.token
		self._lastIssued = tick()
		
		return response.token
	end
end

function Authenticator:ForceInvalidate()
	self._token = nil
	self._lastIssued = -math.huge
end

function Authenticator.new(userId: number): Authenticator
	local self = setmetatable({
		_userId = userId >= 0 and userId or 0;
		_lastIssued = -math.huge;
		_token = nil;
	}, Authenticator)

	return self :: any
end

return Authenticator
