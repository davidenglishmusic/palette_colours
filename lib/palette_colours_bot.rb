require 'chatterbot/dsl'
require 'rmagick'
include Magick
require 'open-uri'
require_relative 'colour'

class PaletteColoursBot
  DIVISOR = 256
  HEX_FACTOR = 16
  COLOR_LIMIT = 10
  IMAGE_HEIGHT = 50
  IMAGE_WIDTH = 100

  def run
    exclude 'http://', 'https://'
    blacklist 'mean_user, private_user'
    use_streaming true

    replies do |tweet|
      next if tweet.media.empty?
      photo = tweet.media.first
      next unless photo.is_a? Twitter::Media::Photo
      image = Magick::ImageList.new
      image_download = open(photo.media_url_https.to_s)
      image.from_blob(image_download.read)

      unsorted_colours = []
      image.quantize(COLOR_LIMIT, RGBColorspace).color_histogram.each do |key, _count|
        colour = Colour.new(key)
        unsorted_colours.push(colour)
      end

      sorted_colours = unsorted_colours.sort { |a, b| a.luminosity <=> b.luminosity }.reverse

      palette_image = Magick::ImageList.new
      palette_image.new_image(IMAGE_WIDTH, IMAGE_HEIGHT)

      width_increment = IMAGE_WIDTH / sorted_colours.count

      top_left = 0
      top_right = top_left + width_increment

      sorted_colours.each do |colour|
        rect = Magick::Draw.new
        rect.fill(colour.rgb)
        rect.rectangle(top_left, 0, top_right, IMAGE_HEIGHT)
        rect.draw(palette_image)
        top_left += width_increment
        top_right += width_increment
      end

      palette = sorted_colours.map(&:hex)

      palette_image.write('palette.png')
      media = File.open('palette.png')

      tweet "@#{tweet.user.screen_name} Hex codes: #{palette.join(', ')}", { media: media }, tweet
    end
  end
end
