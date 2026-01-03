--!strict

local HttpService = game:GetService("HttpService")

local Http = {}

local AuthenticatorType = require("./authenticatorType")
type Authenticator = AuthenticatorType.Authenticator

local Config = require("./config")
local Schemas = require("./schemas")
local Retry = require("./retry")

type HttpMethod = "GET" | "POST"
type HttpQuery = {[string]: string}
type HttpHeaders = {[string]: string | Secret}
type HttpContentType = "application/json" | "application/json; charset=utf-8" | "application/octet-stream"

type BaseHttpRequestOptions = {
	path: string;
}

type HttpRequestOptions = BaseHttpRequestOptions & {
	method: HttpMethod;
	contentType: HttpContentType;
	body: any;
	query: HttpQuery?;
	headers: HttpHeaders?;
	token: Authenticator?;
}

type JsonHttpRequestOptions = BaseHttpRequestOptions & {
	method: HttpMethod;
	query: HttpQuery?;
	headers: HttpHeaders?;
	token: Authenticator?;
	body: any;
}

type BasicHttpResponse = {
	succeeded: boolean;
	code: number;
	message: string;
	headers: HttpHeaders;
	body: string;
}

type Response = {
	new: (BasicHttpResponse) -> Response;
	__index: Response;

	ExpectSuccess: (self: Response, onErrorMessage: string?) -> Response;
	ExpectContentType: (self: Response, contentType: HttpContentType, onErrorMessage: string?) -> Response;

	AsJson: (self: Response) -> any;
	AsBuffer: (self: Response) -> buffer;
	AsString: (self: Response) -> string;
	AsNumber: (self: Response) -> number;

	read basicResponse: BasicHttpResponse;
}

local Response: Response = {} :: any
Response.__index = Response

function Response.new(basicResponse: BasicHttpResponse): Response
	return setmetatable({
		basicResponse = basicResponse;
	}, Response) :: Response
end

function Response:ExpectSuccess(onErrorMessage: string?)
	if not self.basicResponse.succeeded then
		error(`{onErrorMessage}{if onErrorMessage then " - " else ""}{self.basicResponse.code} {self.basicResponse.message}: {self.basicResponse.body}`)
	else
		return self
	end
end

function Response:ExpectContentType(contentType: HttpContentType, onErrorMessage: string?)
	local actualContentType = (Http.GetHeader(self.basicResponse.headers, "Content-Type") or "none"):split(";")[1]
	local expectedContentType = contentType:split(";")[1]

	if actualContentType ~= expectedContentType then
		error(
			`{onErrorMessage}{if onErrorMessage then " - " else ""}unexpected Content-Type, expected {expectedContentType} got {actualContentType} {
				if not self.basicResponse.succeeded then 
					`with error {self.basicResponse.code} {self.basicResponse.message}: {self.basicResponse.body}` else 
					`with code {self.basicResponse.code} {self.basicResponse.message}`
			}`
		)
	else
		return self
	end
end

function Response:AsJson()
	return HttpService:JSONDecode(self.basicResponse.body)
end

function Response:AsBuffer()
	return buffer.fromstring(self.basicResponse.body)
end

function Response:AsString()
	return self.basicResponse.body
end

local NaN = 0/0

function Response:AsNumber()
	return tonumber(self.basicResponse.body) or NaN
end

-- TODO: URI Encoding
function Http.BuildQuery(query: HttpQuery): string
	local queryString = ""
	local firstKey = true

	for key, value in query do
		queryString ..= `{if firstKey then "?" else "&"}{HttpService:UrlEncode(key)}={HttpService:UrlEncode(value)}`
		firstKey = false
	end

	return queryString
end

function Http.GetHeader(headers: HttpHeaders, header: string): string?
	local lower = header:lower()

	for key, value in headers do
		if key == lower and typeof(value) == "string" then
			return value
		end
	end

	return nil
end

function Http.MakeRequest(options: HttpRequestOptions)
	local headers: HttpHeaders = options.headers or {} 
	
	if options.contentType then
		headers["Content-Type"] = options.contentType
	end

	if options.token then
		local status = Retry(function() return options.token:GetToken() end)

		if not status.succeeded then
			return Response.new({
				succeeded = false;
				headers = {};
				code = 0;
				message = "Retry Fail";
				body = status.error
			})
		end

		headers["Authorization"] = `Bearer {status.returned}`
	end

	local request = HttpService:RequestAsync{
		Url = `{Config.BACKEND_URL}{options.path}{Http.BuildQuery(options.query or {})}`,
		Method = options.method,
		Headers = headers :: any,
		Body = options.body,
		Compress = if typeof(options.body) == "string" and #options.body > 512 then Enum.HttpCompression.Gzip else Enum.HttpCompression.None
	}

	return Response.new({
		succeeded = request.Success;
		headers = request.Headers :: any;
		code = request.StatusCode;
		message = request.StatusMessage;
		body = request.Body or ""
	})
end

function Http.MakeJsonRequest(jsonOptions: JsonHttpRequestOptions)
	local options: HttpRequestOptions = jsonOptions :: any
	options.contentType = "application/json; charset=utf-8"
    options.body = HttpService:JSONEncode(jsonOptions.body)

	return Http.MakeRequest(options)
end

type HttpServiceResponse = typeof(HttpService:RequestAsync({Url="",Compress=Enum.HttpCompression.None;}))

-- this is implemented here so that authenticator doesn't do cyclic requires
-- all other requests should be implemented in requests.luau
function Http.AuthHandshake(key: Secret, userId: number): Schemas.HandshakeResponse
	return Http.MakeJsonRequest{method = "POST"; path = "/auth/handshake"; body = {userId = userId}; headers = {["X-Roblox-Secret"] = key}}
		:ExpectSuccess("Authentication failure")
		:ExpectContentType("application/json", "Authentication was malformed")
		:AsJson()
end

return Http