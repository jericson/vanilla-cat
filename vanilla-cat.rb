#!/usr/bin/env ruby -W1
# encoding: UTF-8

require 'httparty'
require 'json'
require 'htmlentities'
require 'date'


def transverse_category (cats)
  puts "<ul>"
  cats.each do | category |
    name = category['name']
    url = category['url']

        
    puts "<item><a href='#{ url }'>#{ name }</a></item>"

    transverse_category (category['children'])
  end
  puts "</ul>"
end

def get_categories (uri)

  response = HTTParty.get(uri)
  case response.code
    when 200
      return JSON.parse(response.body)

  end
end

require 'optparse'

options ={
  :depth => 100
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} SITE ..."

  opts.on("-d", "--depth N", "Site") do |d|
    options[:depth] = d
  end
  
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

puts "<html><head></head><body>"

ARGV.each do | site |
  cats = get_categories("https://#{ site}/api/v2/categories?maxDepth=#{ options[:depth] }&archived=false&page=1&limit=100")

 
  transverse_category (cats)
end
  
puts "</body></html>"
