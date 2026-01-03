--!strict

local Http = require("./http")
local Schemas = require("./schemas")
local AuthenticatorType = require("./authenticatorType")
type Authenticator = AuthenticatorType.Authenticator

local Requests = {}

function Requests.CheckAlive(): Schemas.CheckAliveResponse
	return Http.MakeRequest{method = "GET"; path = "/status/test";}
		:ExpectSuccess("Failed check if server is alive")
		:AsJson()
end

function Requests.ObtainUnlockable(token: Authenticator, payload: Schemas.UnlockableSetRequest): Schemas.SuccessResponse
	return Http.MakeJsonRequest{method = "POST"; path = "/unlockables/set"; body = payload; token = token;}
		:ExpectSuccess("Failed to set unlockable")
		:AsJson()
end

-- GET /unlockables/get/
function Requests.GetUnlockables(token: Authenticator): Schemas.UnlockableGetResponse
	return Http.MakeRequest{method = "GET"; path = `/unlockables/get/`; contentType = "application/json"; token = token;}
		:ExpectSuccess("Failed to fetch unlockables")
		:ExpectContentType("application/json", "Unlockables was malformed")
		:AsJson()
end

-- POST /base/save?name=...
function Requests.SaveBase(token: Authenticator, payload: Schemas.BaseSavePayload): Schemas.SuccessResponse
	return Http.MakeRequest{method = "POST"; path = "/base/save"; query = {name = payload.name}; contentType = "application/octet-stream"; body = buffer.tostring(payload.content); token = token;}
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

-- PATCH /base/rename?name=...
function Requests.RenameBase(token: Authenticator, payload: Schemas.BaseRenameQueryParams): Schemas.SuccessResponse
	return Http.MakeJsonRequest{method = "PATCH"; path = "/base/rename"; query = {oldName = payload.oldName; newName = payload.newName;}; token = token;}
		:ExpectSuccess("Failed to rename base")
		:ExpectContentType("application/json", "Base rename response was malformed")
		:AsJson()
end

-- DELETE /base/delete?name=...
function Requests.DeleteBase(token: Authenticator, payload: Schemas.BaseDeleteQueryParams): Schemas.SuccessResponse
    return Http.MakeRequest{method = "DELETE"; path = "/base/delete"; query = {name = payload.name}; token = token;}
        :ExpectSuccess("Failed to delete base")
        :ExpectContentType("application/json", "Response was malformed")
        :AsJson()
end

-- POST /log/send
function Requests.SendLog(token: Authenticator, payload: Schemas.LogSendRequest): Schemas.SuccessResponse
	return Http.MakeJsonRequest{method = "POST"; path = "/log/send"; body = payload; token = token;}
		:ExpectSuccess("Failed to send log")
		:ExpectContentType("application/json", "log response was malformed")
		:AsJson()
end

return Requests
