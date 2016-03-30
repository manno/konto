#!/usr/bin/env ruby
# Collect and convert Postbank CSV

require 'csv'
require 'time'
require 'optparse'

options = { infiles: 'db/*csv', outfile: 'kontoumsatz.csv' }

OptionParser.new do |opts|
  opts.banner = 'Usage: akkumulation_csv.rb [options]'

  opts.on('-iNAME', '--in=NAME', 'input directory glob') do |v|
    options[:infiles] = v
  end

  opts.on('-oNAME', '--out=NAME', 'output file') do |v|
    options[:outfile] = v
  end

  opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
    options[:verbose] = v
  end
end.parse!

def parse_date(t)
  Time.parse(t).strftime('%d.%m.%Y')
end

def get_search_key(row)
  key = row[0] + row[4] + row[6]
  key.downcase
end

def currency(v)
  v.delete('.').tr(',', '.')
end

seen = {}
data = []
Dir.glob(options[:infiles]).sort.each do |file|
  c = CSV.open(file, encoding: 'iso-8859-15', col_sep: ';')
  c.drop(8).each do |row|
    key = get_search_key(row)
    if seen.key?(key)
      puts "skipping #{key}"
      next
    end
    seen[key] = 1
    data << row
  end
end

CSV.open(options[:outfile], 'wb', encoding: 'utf-8', col_sep: ';') do |csv|
  data.each do |row|
    row[6] = currency(row[6][0..-3])
    row[7] = currency(row[7][0..-3])
    csv << row
  end
end
