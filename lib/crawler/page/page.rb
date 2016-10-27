# page.rb
require "crawler/report/page_diff"
require 'crawler/page/simple_code'
require 'crawler/page/to_object'
require 'crawler/db'
require 'crawler/db/sql'
require 'digest/sha1'

module Crawler
	module Page
		class Page
			attr_accessor :page_type, :sp, :url, :title, :description, 
							:content, :nokogiri_object, :diff_hash, :attributes_item, :invalid_item

			include SimpleCode
			include ToObject
			include DB::SQL

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

			def get_base_url
				self.url.split("/")[0..-2].join("/")
			end

			def get_sp
				Digest::SHA1.hexdigest(self.sp.keys.join.gsub("-", ""))
			end

			def save
				@dbh = DB.Connection

				# save page_category unless url_exist? self.url
				@dbh.query(sql_insert_page_category(get_base_url, get_sp)) unless url_exist? self.url
				page_category_id = @dbh.last_id
				printf "Page Category ID: %d\n", page_category_id

				# except repeat save atrribute and reinit @attributes_item
				save_new_attributes
				puts "Attributes ID List: #{@attributes_item.map{|item|item[:id]}}"

				# save pc_attr unless attr id list nil
				@dbh.query(sql_insert_pc_attr(@attributes_item, page_category_id))
				puts "PC Attr Save Done."
				# save page
				@dbh.query(sql_insert_page(page_category_id, Page::DETAIL, @url, @title, @description, @content))
				page_id = @dbh.last_id
				printf "Page Save Done, Page ID: %d\n", page_id
				# save page attr
				save_page_attr_value page_id
				puts "Page Attr Value Save Done."
			end
			private
			def save_page_attr_value page_id
				@attributes_item.each do |item|
					attr_value = @nokogiri_object.at_xpath(item[:path]).text()[item[:name].size..-1]
					@dbh.query(sql_insert_page_attr(page_id, item[:id], attr_value))
				end
			end

			def save_new_attributes
				#** it's would take too long time, need to be enhancement.
				# if there has some attribute exist in database, then set id for it.
				result = @dbh.query(sql_confirm_attribute_exist @attributes_item.map{|x|x[:name]}.join("\",\""))
				@attributes_item.collect do |row|
					row[:id] = result.find{|x|x["name"]==row[:name]}["id"] rescue nil
				end
				# insert
				sql = sql_insert_attributes(@attributes_item)
				@dbh.query(sql) unless sql.nil?
				# get max record id after insert
				to_id = @dbh.last_id
				# update @attributes_item where new insert record's id column
				id_nil_items = @attributes_item.select{|item|item[:id].nil?}
				id_nil_items_size = id_nil_items.size
				id_nil_items.collect do |x|
					x[:id] = to_id - id_nil_items_size + 1
					id_nil_items_size -= 1
				end
			end
		end
	end
end