--!strict

local EncodingService = game:GetService("EncodingService")

local Http = require("./http")
local Schemas = require("./schemas")
local AuthenticatorType = require("./authenticatorType")

type Authenticator = AuthenticatorType.Authenticator

local Requests = {}

-- GET /status/test
function Requests.CheckAlive(): Schemas.CheckAliveResponse
	return Http.MakeRequest{method = "GET"; path = "/status/test";}
		:ExpectSuccess("Failed check if server is alive")
		:AsJson()
end

-- POST /unlockables/set
function Requests.ObtainUnlockable(token: Authenticator, payload: Schemas.UnlockableSetRequest): Schemas.SuccessResponse
	return Http.MakeJsonRequest{method = "POST"; path = "/unlockables/set"; body = payload; token = token;}
		:ExpectSuccess("Failed to set unlockable")
		:AsJson()
end

-- GET /unlockables/get
function Requests.GetUnlockables(token: Authenticator): Schemas.UnlockableGetResponse
	return Http.MakeRequest{method = "GET"; path = "/unlockables/get"; token = token;}
		:ExpectSuccess("Failed to fetch unlockables")
		:ExpectContentType("application/json", "Unlockables was malformed")
		:AsJson()
end

-- POST /base/save?name=...
function Requests.SaveBase(token: Authenticator, payload: Schemas.BaseSavePayload): Schemas.SuccessResponse
	return Http.MakeRequest{method = "POST"; path = "/base/save"; contentType = "application/octet-stream"; query = {name = payload.name}; body = buffer.tostring(payload.content); token = token;}
		:ExpectSuccess("Failed to save base")
		:ExpectContentType("application/json", "Base save response was malformed")
		:AsJson()
end

-- GET /base/list
function Requests.ListBases(token: Authenticator): Schemas.BaseListResponse
	return Http.MakeRequest{method = "GET"; path = "/base/list"; token = token;}
		:ExpectSuccess("Failed to list bases")
		:ExpectContentType("application/json", "Base list response was malformed")
		:AsJson()
end

-- PATCH /base/rename?name=...
function Requests.RenameBase(token: Authenticator, payload: Schemas.BaseRenameQueryParams): Schemas.SuccessResponse
	return Http.MakeRequest{method = "PATCH"; path = "/base/rename"; contentType = "application/octet-stream", query = {oldName = payload.oldName; newName = payload.newName;}; token = token;}
		:ExpectSuccess("Failed to rename base")
		:ExpectContentType("application/json", "Base rename response was malformed")
		:AsJson()
end

-- GET /base/list
function Requests.LoadBase(token: Authenticator, payload: Schemas.BaseLoadPayload): buffer
	return Http.MakeRequest{method = "GET"; path = "/base/load"; query = {name = payload.name}; token = token;}
		:ExpectSuccess("Failed to load base")
		:ExpectContentType("application/octet-stream", "Base response was malformed")
		:AsBuffer()
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

-- yes ik this has no defined schema but the sba code is ancient and idc to define it when the type solver wouldn't even work there anyways
-- GET /perms/get
function Requests.GetPerms(): any
	return Http.MakeRequest{method = "GET"; path = "/perms/get";}
		:ExpectSuccess("Failed to list bases")
		:ExpectContentType("application/json", "Base list response was malformed")
		:AsJson()
end

return Requests
