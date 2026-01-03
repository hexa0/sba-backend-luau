--!strict

local task = task

type RetryOptions = {
	maxAttempts: number?;
	initialDelay: number?;
	backoffMultiplier: number?;
}

type RetryStatus<T> = {
	succeeded: boolean;
	returned: T;
	error: string;
}

local function Retry<T>(callback: () -> T, options: RetryOptions?): RetryStatus<T>
	local maxAttempts = options and options.maxAttempts or 3
	local delayTime = options and options.initialDelay or 1
	local multiplier = options and options.backoffMultiplier or 2

	local attempts = 0

	while true do
		attempts += 1

		local result = { pcall(callback) }
		local success = result[1]

		if success then
			return {
				succeeded = true;
				returned = result[2] :: any;
				error = "";
			}
		end

		local errorMessage: string = result[2] :: any

		if attempts >= maxAttempts then
			return {
				succeeded = false;
				returned = result[2] :: any;
				error = `Max retry attempts reached ({maxAttempts}). Last error: {errorMessage}`;
			}
		end

		warn(`Attempt {attempts} failed: {errorMessage}. Retrying in {delayTime}s...`)

		task.wait(delayTime)
		delayTime *= multiplier
	end
end

return Retry