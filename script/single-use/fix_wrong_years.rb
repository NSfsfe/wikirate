require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

require "csv"

FILENAME = File.expand_path "data/wrong_year.csv"

def csv
  CSV.new raw, headers: true
end

def raw
  File.read FILENAME
end

def fetch id
  Card.fetch id.to_i
end

def card_ok id
  card = Card[id]
  return card if card

  puts "could not find card with id #{id}"
  false
end

def year_ok year, card
  return year unless year == card.year

  puts "year is already correct: #{card.name}"
  false
end

def name_ok year, card
  new_name = Card::Name[card.name.left, year]
  return new_name unless Card[new_name]

  puts "card already exists: #{new_name}"
  false
end

csv.each do |r|
  next unless
    (card = card_ok r["Answer ID"]) &&
    (year = year_ok r["Correct Year"], card) &&
    (name = name_ok year, card)
  puts "renaming: #{card.name}\n     to: #{name}"
  card.update! name: name
end

puts "done."
