# page.rb

require 'nokogiri'
require 'open-uri'
require 'crawler/page/simple_code'
# require 'crawler/page/modularization'
# require 'crawler/page/to_object'

module Crawler
	module Page

		class << self

			def SimpleCode(url)
				SimpleCode.new url
			end
		end
	end
end