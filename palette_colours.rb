require_relative 'lib/palette_colours_bot'

File.open('palette_colours.yml', 'w') do |f|
  f << "---\n"
  f << ":consumer_key: #{ENV['TWITTER_CONSUMER_KEY']}\n"
  f << ":consumer_secret: #{ENV['TWITTER_CONSUMER_SECRET']}\n"
  f << ":access_token: #{ENV['TWITTER_ACCESS_TOKEN']}\n"
  f << ":access_token_secret: #{ENV['TWITTER_ACCESS_TOKEN_SECRET']}\n"
end

PaletteColoursBot.new.run
