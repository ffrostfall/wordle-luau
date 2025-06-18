local fs = require("@lune/fs")

local memoized_words: { string }? = nil

local function pull_words(): { string }
	if memoized_words then
		return memoized_words
	end

	local file_string = fs.readFile("./word_list.txt")

	memoized_words = string.split(file_string, "\n")
	assert(memoized_words)

	-- eol newline
	local index = table.find(memoized_words, "\n")
	if index then
		table.remove(memoized_words, index)
	end

	return memoized_words
end

return pull_words
