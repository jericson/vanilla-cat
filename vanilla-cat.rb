#!/usr/bin/env ruby -W1
# encoding: UTF-8

require 'httparty'
require 'json'
require 'htmlentities'
require 'date'


def transverse_category (cats, options)
  puts "<ul>"
  cats.each do | category |
    item  = "<item>"
    item += "<a href='#{ category['url'] }'>#{ category['name'] }</a>"
    item += " ( #{ category['countDiscussions'] } Threads" +
            " | #{ category['countComments'] } Replies)" if options[:stats]
    item += "</item>"
    puts item

    transverse_category(category['children'], options)
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
  :depth => 100,
  :stats => false
}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} SITE ..."

  opts.on("-d", "--depth N", "Depth of search") do |d|
    options[:depth] = d
  end

  opts.on( '-s', '--stats', 'Include category stats' ) do
    options[:stats] = true
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

 
  transverse_category(cats, options)
end
  
puts "</body></html>"
