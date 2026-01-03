--!strict

export type Authenticator = {
	__index: Authenticator;
	new: (userId: number) -> Authenticator;

	GetToken: (self: Authenticator) -> string;
	IsExpired: (self: Authenticator) -> boolean;
	ForceInvalidate: (self: Authenticator) -> ();
	
	_userId: number;
	_token: string?;
	_lastIssued: number;
}

return 0