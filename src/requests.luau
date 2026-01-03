--!strict

local Http = require("./http")
local Schemas = require("./schemas")
local AuthenticatorType = require("./authenticatorType")
type Authenticator = AuthenticatorType.Authenticator

local Requests = {}

function Requests.SetUnlockable(token: Authenticator, payload: Schemas.UnlockableSetRequest): { success: boolean }
	return Http.MakeJsonRequest{method = "POST"; path = "/unlockables/set"; body = payload; token = token;}
		:ExpectSuccess("Failed to set unlockable")
		:AsJson()
end

-- GET /unlockables/get/:userId
function Requests.GetUnlockables(userId: number): { string }
	return Http.MakeRequest{method = "GET"; path = `/unlockables/get/{userId}`; contentType = "application/json";}
		:ExpectSuccess("Failed to fetch unlockables")
		:ExpectContentType("application/json", "Unlockables was malformed")
		:AsJson()
end

-- POST /base/save?name=...
function Requests.SaveBase(token: Authenticator, name: string, content: buffer): { success: boolean }
	return Http.MakeRequest{method = "POST"; path = "/base/save"; query = {name = name}; contentType = "application/octet-stream"; body = buffer.tostring(content); token = token;}
		:ExpectSuccess("Failed to save base")
		:ExpectContentType("application/json", "Base save response was malformed")
		:AsJson()
end

-- GET /base/list
function Requests.ListBases(token: Authenticator): Schemas.BaseListResponse
	return Http.MakeRequest{method = "GET"; path = "/base/list"; contentType = "application/json"; token = token;}
		:ExpectSuccess("Failed to list bases")
		:ExpectContentType("application/json", "Base list response was malformed")
		:AsJson()
end

-- POST /log/send
function Requests.SendLog(token: Authenticator, payload: Schemas.LogSendRequest): { success: boolean }
	return Http.MakeJsonRequest{method = "POST"; path = "/log/send"; body = payload; token = token;}
		:ExpectSuccess("Failed to send log")
		:ExpectContentType("application/json", "log response was malformed")
		:AsJson()
end

return Requests
