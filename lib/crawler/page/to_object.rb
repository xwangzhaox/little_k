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
				@invalid_item = []
				@attributes_item = []
				@diff_hash[:diff].each do |diff_item|					
					left_content, right_content = get_both_content diff_item
					unless re_init_title_or_description left_content, right_content # 从新定义title和description
						# 拉取attribute列表
						attr_name = get_attribute left_content[0..20].gsub(" ", ""), right_content[0..20].gsub(" ", "")
						if attr_name.nil? or attr_name==""
							(@invalid_item << diff_item.keys[0])
						else
							(@attributes_item << {:name => attr_name, :path => diff_item.values[0].values[0][:xpath]})
						end
					end
				end
			end

			def re_init_title_or_description str1, str2
				if str1.size<150 and is_title? str1
					@title = str1
					return true
				elsif is_description? str1
					@description = str1
					return true
				end
				return false
			end

			# e.g. {"3-2-2-7-1-1"=>{:l=>{:name=>"span", :id=>nil, :class=>"stockName", :content=>"中房地产(SZ:000736)", :xpath=>"/html/body/div[3]/div[2]/div[2]/div[1]/div[1]/span[1]"},:r=>{:name=>"span", :id=>nil, :class=>"stockName", :content=>"中国电影(SH:600977)", :xpath=>"/html/body/div[3]/div[2]/div[2]/div[1]/div[1]/span[1]"}}}
			def get_both_content hash
				result = hash.values.map(&:values)[0].map{|i|i[:content]}
				return result.first, result.last
			end

			def get_attribute str1, str2
				str1.split(/[^'’[^\p{P}]]/).first == str2.split(/[^'’[^\p{P}]]/).first ?
					str1[/[\u4E00-\u9FA5]*/] : nil
			end
		end
	end
end