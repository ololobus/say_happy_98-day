#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

require 'prawn'
require 'prawn/measurement_extensions'

OPEN_SYM = '{'
CLOSE_SYM = '}'
PAGE_WIDTH = 210 # mm
PAGE_HEIGHT = 297 # mm

options = OpenStruct.new({
  base_color: '0D4F8B',
  highlight_color: 'E3170D',
  text: 'Say hello {%username}!'
})

OptionParser.new do |opt|
  opt.on('-t', '--text TEXT', 'Text to print')               { |o| options[:text] = o }
  opt.on('-c1', '--base-color TEXT', 'Base color')           { |o| options[:base_color] = o }
  opt.on('-c2', '--highlight-color TEXT', 'Highlight color') { |o| options[:highlight_color] = o }
  opt.on('-o', '--output-file TEXT', 'Output file name')     { |o| options[:output] = o }
end.parse!

chars_count = options
  .text
  .gsub(OPEN_SYM, '')
  .gsub(CLOSE_SYM, '')
  .size
avg_area = PAGE_WIDTH * PAGE_HEIGHT / chars_count
avg_side = Math.sqrt(avg_area)

n_rows = (PAGE_HEIGHT / avg_side).ceil
n_cols = (PAGE_WIDTH / avg_side).floor

box_w = PAGE_WIDTH.mm / n_cols
box_h = PAGE_HEIGHT.mm / n_rows

# p options.text
# p avg_area
# p avg_side
# p box_w, box_h
# p n_rows
# p n_cols

Prawn::Document.generate(options.output || 'postcard.pdf') do
  curr_color = options.base_color
  curr_row = 1
  curr_col = 0

  options.text.split('').each do |c|
    if c == OPEN_SYM
      curr_color = options.highlight_color
      next
    elsif c == CLOSE_SYM
      curr_color = options.base_color
      next
    end

    curr_col += 1
    if curr_col > n_cols
      curr_row += 1
      curr_col = 1
    end

    # p c.ord

    float do
      bounding_box(
        [(curr_col - 1) * box_w,
         PAGE_HEIGHT.mm - (curr_row) * box_h],
        width: box_w,
        height: box_h) do

        text "#{c.ord}", color: curr_color, size: avg_side * 0.2.mm
      end
    end
  end
end
