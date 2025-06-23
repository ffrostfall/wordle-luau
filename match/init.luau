local richterm = require("@shared/richterm")
local pull_words = require("@shared/pull_words")

local yellow = richterm.yellow
local green = richterm.green
local gray = richterm.gray

export type GuessResult = "correct" | "wrong-place" | "incorrect"
export type Guess = { [number]: { character: string, result: GuessResult } }

type Outcome = "won" | "lost" | "undecided"

export type GameState = {
	guesses: { Guess },

	outcome: Outcome,
	hidden_word: string,
}

local match = {}

function match.create_match(force_word: string?): GameState
	local words = pull_words()

	return {
		guesses = {},

		outcome = "undecided",
		hidden_word = force_word or words[math.random(1, #words)],
	}
end

function match.render_match(game_state: GameState): string
	local formatted_guesses = {}

	for guess_num, guess in game_state.guesses do
		local rendered_guess = {}

		for i, character in guess do
			local color_fmt = if character.result == "correct"
				then green
				elseif character.result == "wrong-place" then yellow
				else gray

			rendered_guess[i] = color_fmt(character.character)
		end

		table.insert(formatted_guesses, `[{guess_num}]: [{table.concat(rendered_guess, "")}]\n`)
	end

	local appended = ""

	if game_state.outcome == "won" then
		appended = "won"
	elseif game_state.outcome == "lost" then
		appended = `lost, the word was {game_state.hidden_word}`
	else
		appended = `{6 - #game_state.guesses} guesses left.`
	end

	return `{table.concat(formatted_guesses)}\n{appended}`
end

function match.guess(game_state: GameState, word: string)
	assert(#word == 5, `invalid string length {#word}`)
	assert(game_state.outcome == "undecided", "attempt to guess on complete game")

	local guess: Guess = {}

	-- preparation for post pass
	local character_occurances: { [string]: number } = {}
	local correct_character_guesses: { [string]: number } = {}
	local wrong_place_guesses: { [string]: number } = {}

	-- prepass: count character occurrances in word
	for i = 1, 5 do
		local char = string.sub(game_state.hidden_word, i, i)
		character_occurances[char] = (character_occurances[char] or 0) + 1
	end

	for i = 1, 5 do
		local character = string.sub(word, i, i)
		local hidden_word_character = string.sub(game_state.hidden_word, i, i)

		if hidden_word_character == character then
			correct_character_guesses[character] = (correct_character_guesses[character] or 0) + 1
			guess[i] = {
				character = character,
				result = "correct",
			}
		elseif string.find(game_state.hidden_word, character) then
			wrong_place_guesses[character] = (wrong_place_guesses[character] or 0) + 1

			if wrong_place_guesses[character] <= character_occurances[character] then
				guess[i] = {
					character = character,
					result = "wrong-place",
				}
			else
				guess[i] = {
					character = character,
					result = "incorrect",
				}
			end
		else
			guess[i] = {
				character = character,
				result = "incorrect",
			}
		end
	end

	for _, guess_character in guess do
		-- if it's the wrong place, and the # of correct chars == # of occurrances,
		-- we should flip it to incorrect.
		if not character_occurances[guess_character.character] then
			continue
		end

		if guess_character.result ~= "wrong-place" then
			continue
		end

		if character_occurances[guess_character.character] == correct_character_guesses[guess_character.character] then
			guess_character.result = "incorrect" :: any
		end
	end

	table.insert(game_state.guesses, guess)

	if game_state.hidden_word == word then
		game_state.outcome = "won" :: any
	elseif #game_state.guesses == 6 then
		game_state.outcome = "lost" :: any
	end
end

return match
