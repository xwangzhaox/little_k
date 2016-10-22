# page.rb
require "crawler/report/page_diff"
require 'crawler/page/simple_code'
require 'crawler/page/to_object'

module Crawler
	module Page
		class Page
			attr_accessor :page_type, :sp, :url, :title, :description, 
							:content, :nokogiri_object, :diff_hash

			include SimpleCode
			include ToObject

			# page type
			DETAIL = 0
			LIST = 1
			HOME = 2
			OTHER = 3

			def initialize(options)
				page             = Nokogiri::HTML(open(options[:url]))
				@url             = options[:url]
				@title           = page.at('//title').text() rescue nil
				@description     = page.at('//description').text() rescue nil
				@nokogiri_object = page.css('body')
				@sp              = scan_html_structrue @nokogiri_object, nil, true
				@report          = Report::PageDiff.new({:first_url => @url})
			end

			["title", "description"].each do |attr|
				define_method("is_#{attr}?") do |str|
					i = 0
					str.split(/[^'’[^\p{P}]]/).each do |word|
						i += 1 if eval("@#{attr}") and eval("@#{attr}.include? '#{word}'")
					end
					i > 0 ? true : false
				end
			end

			def url_exist?(url)
				false
			end

			def confirm_page_type
				# do somthing
				@page_type = Page::DETAIL
			end

			def stru_record_exist?
				# 查询数据库判断 @sp 是否存在
				false
			end
		end
	end
end