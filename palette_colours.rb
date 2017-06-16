require 'chatterbot/dsl'
require 'rmagick'
include Magick
require 'open-uri'

DIVISOR = 256
HEX_FACTOR = 16
COLOR_LIMIT = 10

File.open('palette_colours.yml', 'w') do |f|
  f << "---\n"
  f << ":consumer_key: #{ENV['TWITTER_CONSUMER_KEY']}\n"
  f << ":consumer_secret: #{ENV['TWITTER_CONSUMER_SECRET']}\n"
  f << ":access_token: #{ENV['TWITTER_ACCESS_TOKEN']}\n"
  f << ":access_token_secret: #{ENV['TWITTER_ACCESS_TOKEN_SECRET']}\n"
end

exclude 'http://', 'https://'

blacklist 'mean_user, private_user'

use_streaming true

replies do |tweet|
  next if tweet.media.empty?
  # replace the incoming username with #USER#, which will be replaced
  # with the handle of the user who tweeted us by the
  # replace_variables helper
  photo = tweet.media.first
  next unless photo.is_a? Twitter::Media::Photo
  image = Magick::ImageList.new
  image_download = open(photo.media_url_https.to_s)
  image.from_blob(image_download.read)
  top_colors = image.color_histogram.sort_by { |_k, v| v }.reverse.first(COLOR_LIMIT).map do |tuple|
    pixel = tuple.first
    "#{(pixel.red / DIVISOR).to_s(HEX_FACTOR)}#{(pixel.green / DIVISOR).to_s(HEX_FACTOR)}#{(pixel.blue / DIVISOR).to_s(HEX_FACTOR)}"
  end
  reply "@#{tweet.user.screen_name} Hex codes: #{top_colors.join(', ')}", tweet
end
