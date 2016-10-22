# to_object.rb

module Crawler
	module Page
		module ToObject

			def first_child
				# @diff_hash.first[0].values[0][:xpath] 示例数据如下：
				# [{"3-2-2-7-1-1"=>{:name=>"span", :id=>nil, :class=>"stockName", :content=>"中房地产(SZ:000736)", :xpath=>"/html/body/div[3]/div[2]/div[2]/div[1]/div[1]/span[1]"}}, {"3-2-2-7-1-1"=>{:name=>"span", :id=>nil, :class=>"stockName", :content=>"中国电影(SH:600977)", :xpath=>"/html/body/div[3]/div[2]/div[2]/div[1]/div[1]/span[1]"}}]
				puts @page.nokogiri_object.at_xpath(@page.diff_hash.first[0].values[0][:xpath]).to_html
			end

			def objectification
				@diff_hash[:diff].each do |diff_item|
					html = @nokogiri_object.at_xpath(diff_item[0].values[0][:xpath]).to_html
					content = get_entity_attr html.gsub(/<\/?.*?>/, "")
					get_entity_attr content unless content.nil?
				end
			end

			def get_entity_attr content
				if content.size<150 and is_title? content
					@title = content
				elsif is_description? content
					nil
				# elsif attr_exist
				# 	break
				else
					#不存在
					nil
				end
			end
		end
	end
end