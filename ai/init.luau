local match = require("@game/")

local pull_words = require("@shared/pull_words")

local word_list = pull_words()

local function narrow_word_list_from_guess(existing_list: { string }, guess: match.Guess): { string }
	-- for
	local exclude_characters_completely: { string } = {}
	local exclude_characters_in_spot: { [number]: { string } } = {}
	local correct_characters: { string } = {}
	local wrong_place_characters: { string } = {}

	-- through to find
	for i = 1, 5 do
	end

	-- go through words
	local words = {}

	return words
end

local ai = {}

function ai.play()
	local ai_match = match.create_match()

	-- crane is a good opener
	match.guess(ai_match, "crane")
end

return ai
