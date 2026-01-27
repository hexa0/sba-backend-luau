local Schemas = {}

-- generic success response
export type SuccessResponse = {
    success: boolean;
	error: string?;
}

-- /status/test response
export type CheckAliveResponse = SuccessResponse & {
	engine: string,
	uptime: number,
	databaseState: "connected" | "disconnected"
}

-- /auth/handshake response
export type HandshakeResponse = SuccessResponse & {
    token: string;
}

-- /unlockables/set request
export type UnlockableSetRequest = {
    name: string;
}

-- /unlockables/get response
export type UnlockableGetResponse = {string}

-- /log/send request
export type LogSendRequest = {
    type: string;
    contents: string;
    adminName: string?;
}

-- /base/save request
export type BaseSavePayload = {
    name: string;
	content: buffer;
}

-- /base/rename request
export type BaseRenameQueryParams = {
    oldName: string;
    newName: string;
}

-- /base/load request
export type BaseLoadPayload = {
    name: string;
}

-- /base/rename request
export type BaseDeleteQueryParams = {
    name: string;
}

-- /base/list response
export type BaseListItem = {
    name: string;
	updatedAt: string; -- ISO Date
	createdAt: string; -- ISO Date
    size: number; -- Bytes
}

export type BaseListResponse = {
	[string]: BaseListItem;
}

return Schemas