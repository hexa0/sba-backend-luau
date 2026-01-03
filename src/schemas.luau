local Schemas = {}

-- /auth/handshake response
export type HandshakeResponse = {
    token: string;
}

-- /unlockables/set request
export type UnlockableSetRequest = {
    userId: number;
    name: string;
}

-- /log/send request
export type LogSendRequest = {
    type: string;
    contents: string;
    adminName: string?;
}

-- /base/save request
export type BaseSaveQueryParams = {
    name: string;
}

-- /base/list/:userId response
export type BaseListItem = {
    file: string;
    size: number;
}
export type BaseListResponse = {
	[string]: BaseListItem;
}

return Schemas