local match = require("@game/")
local stdio = require("@lune/stdio")
local pull_words = require("@shared/pull_words")
local process = require("@lune/process")

local force_word: string? = process.args[1]
local test_match = match.create_match(force_word)
local words = pull_words()

while test_match.outcome == "undecided" do
	print(match.render_match(test_match))

	local word: string? = nil
	while not word do
		local input_word = stdio.prompt("text" :: "text", "input word:")
		if #input_word ~= 5 then
			print("please give a 5 letter word")
			continue
		end

		if not table.find(words, input_word) then
			print(`{input_word} is not in the word list`)
			continue
		end

		word = input_word
	end

	assert(word)

	match.guess(test_match, word)
end

print(match.render_match(test_match))
