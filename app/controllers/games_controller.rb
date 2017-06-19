class GamesController < ApplicationController
require 'open-uri'
require 'json'

def game
  grid_size = 9
  @grid = generate_grid(grid_size)
  @start_time = Time.now
end

def score
  @grid = params[:grid]
  @answer = params[:answer].to_s
  @is_valid = in_the_grid?(@grid, @answer)
  start_time = params[:start_time]
end

def generate_grid(grid_size)
  # 9.times.map { ('A'..'Z').to_a.sample } # F
  grid = []
  grid_size.times { grid << ('A'..'Z').to_a.sample }
  grid = grid.join(" ")
end

def calculate_score(time_spent, attempt, grid)
  return 0 if translation.nil?

  if in_the_grid?(grid, attempt)
    attempt.length / time_spent
  else
    0
  end
end

def in_the_grid?(grid, attempt)
  # attempt.split('').all? { |letter| attempt.count(letter) <= grid.count(letter) }

  local_grid = grid.dup

  attempt.each_char do |letter|
    if local_grid.include?(letter.upcase)
      local_grid.delete(letter.upcase)
    else
      return false
    end
  end
  return true
end

def figure_out_message(grid, attempt, translation)
  return 'not in the grid' unless in_the_grid?(grid, attempt)
  if translation.nil?
    'not an english word'
  else
    'well done'
  end
end

def translate(english_word)
  url = "https://api-platform.systran.net/translation/text/translate?input=#{english_word}&source=en&target=fr&key=f3a823bb-155a-47a8-ae22-2ed070cedd49"

  json_string = open(url).read
  json_hash = JSON.parse(json_string)
  api_result = json_hash['outputs'][0]['output']
  api_result == english_word ? nil : api_result
end

def run_game(attempt, grid, start_time, end_time)
  time_spent = end_time - start_time
  translation = translate(attempt)
  score = calculate_score(time_spent, attempt, grid, translation)
  message = figure_out_message(grid, attempt)

  {
    time: time_spent,
    translation: translation,
    score: score,
    message: message
  }
end
end
