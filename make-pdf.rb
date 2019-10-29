#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

# require 'pry'
require 'prawn'
require 'prawn/measurement_extensions'

OPEN_SYM = '{'
CLOSE_SYM = '}'
PAGE_WIDTH = 210 # mm
PAGE_HEIGHT = 297 # mm

COLORS = OpenStruct.new({
  blue: '0000FF',
  green: '008000',
  red: 'FF0000',
  gray: '808080',
  black: '000000',
  maroon: '800000',
  yellow: 'FFFF00',
  navy: '000080',
  purple: '800080',

  default: '0D4F8B',
  default_highlight: 'E3170D',
})

options = OpenStruct.new({
  base_color: 'default',
  highlight_color: 'default_highlight',
  text: 'Say hello {%username}!',
})

OptionParser.new do |opt|
  opt.on('-t', '--text TEXT', 'Text to print') { |o| options[:text] = o }
  opt.on('-b', '--base-color TEXT', 'Base color') { |o| options[:base_color] = o }
  opt.on('-c', '--highlight-color TEXT', 'Highlight color') { |o| options[:highlight_color] = o }
  opt.on('-o', '--output-file TEXT', 'Output file name') { |o| options[:output] = o }
end.parse!

chars_count = options
  .text
  .gsub(OPEN_SYM, '')
  .gsub(CLOSE_SYM, '')
  .size
avg_area = PAGE_WIDTH * PAGE_HEIGHT / chars_count
avg_side = Math.sqrt(avg_area)

n_rows = (PAGE_HEIGHT / avg_side).ceil
n_cols = (PAGE_WIDTH / avg_side).ceil

box_w = PAGE_WIDTH.mm / n_cols
box_h = PAGE_HEIGHT.mm / n_rows

def get_hex_color(color)
  if COLORS[color] != nil
    # User specified color name, so return hex
    return COLORS[color]
  elsif !color[/\H/] && color.length == 6
    # User specified hex
    return color
  else
    # Something's not right
    puts 'Invalid color specified.'
    exit
  end
end

Prawn::Document.generate(options.output || 'postcard.pdf') do
  curr_color = get_hex_color(options.base_color)
  curr_row = 0
  curr_col = 0

  define_grid(columns: n_cols, rows: n_rows, gutter: 0.1)

  options.text.split('').each do |c|
    if c == OPEN_SYM
      curr_color = get_hex_color(options.highlight_color)
      next
    elsif c == CLOSE_SYM
      curr_color = get_hex_color(options.base_color)
      next
    end

    if curr_col >= n_cols
      curr_row += 1
      curr_col = 0
    end

    grid_box = grid(curr_row, curr_col)

    float do
      bounding_box(
        grid_box.top_left,
        width: grid_box.width,
        height: grid_box.height,
      ) do
        text '#{c.ord}',
             color: curr_color,
             size: avg_side * 0.2.mm,
             align: :center,
             valign: :center
      end
    end

    curr_col += 1
  end

  # binding.pry
  # grid.show_all

end
