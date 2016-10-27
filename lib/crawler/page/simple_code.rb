# simple_code.rb
require "crawler/report/page_diff"
require 'iconv'

module Crawler
	module Page
		module SimpleCode

			# 递归扫描HTML文件结构, 获取网页结构简码
			def scan_html_structrue element, parent_sp = nil, get_stru = false
				i = 1
				hash = {}
				element.children.each do |e|
					next if e.name != "div" and get_stru
					next if ["script", "noscript", "style", "comment"].include? e.name
					sp = parent_sp.nil? ? 
						i.to_s : (parent_sp + "-" + i.to_s)
					hash[sp] = {:name => e.name, :id => e.get_attribute('id'), :class => e.get_attribute('class'), :content => e.content, :xpath => e.path} # "#{e.name}.#{e.get_attribute('class')}"
					i += 1
					# 递归处理
					hash = hash.merge scan_html_structrue e, sp, get_stru
				end
				return hash
			end

			# 输入两个文件，返回他们相异的部分结构简码，判断是否要返回完整相同部分结构简码
			def comparsion_page f2, r_print = true
				@report.second_url = f2
				f2 = Nokogiri::HTML(open(f2)).css('body')
				print "Scan page1 structrue ......"
				hash_1 = scan_html_structrue @nokogiri_object
				print " Done.\nScan page2 structrue ...... "
				hash_2 = scan_html_structrue f2
				print "Done.\n"
				arr_sp1 = hash_1.keys
				arr_sp2 = hash_2.keys

				commen_stru = {}
				diff_stru = { :l => {}, :r => {}, :diff => [] }

				sp1_index = sp2_index = 0 # 输出两个结构的不同点
				print_comparsion if r_print # 画边界
				print "Compare pages ...... "
				loop do
					# 如果连个数组都遍历结束就结束循环
					break if sp1_index >= arr_sp1.size and sp2_index >= arr_sp2.size

					sp1 = arr_sp1[sp1_index]
					sp2 = arr_sp2[sp2_index]
					if sp1 == sp2 # 如果结构简码相同，记录到 commen_stru 里
						if %w(div table tr ul).include? hash_1[sp1][:name] and hash_1[sp1][:class] == hash_2[sp2][:class] # 结构性标签，不考虑内容是否相同，只看class是否一样
							hash_1[sp1][:content] = hash_2[sp2][:content] = "***"
							print_comparsion sp1, sp2, hash_1[sp1], hash_2[sp2] if r_print
							commen_stru[sp1] = [hash_1[sp1], hash_2[sp2]]
						elsif hash_1[sp1].eql? hash_2[sp2]
							print_comparsion sp1, sp2, hash_1[sp1], hash_2[sp2] if r_print
							commen_stru[sp1] = [hash_1[sp1], hash_2[sp2]]
						else
							print_comparsion sp1, sp2, hash_1[sp1], hash_2[sp2] if r_print
							diff_stru[:diff] << {sp1 => {:l => hash_1[sp1], :r => hash_2[sp2]}}
						end
						sp1_index += 1
						sp2_index += 1
					elsif sp1.nil? or sp2.nil? # 如果一个结构简码数组遍历结束，剩余部分按照不同
						if sp1.nil?
							print_comparsion nil, sp2, nil, hash_2[sp2] if r_print
							diff_stru[:r][sp2] = hash_2[sp2]
						else
							print_comparsion sp1, nil, hash_1[sp1], nil if r_print
							diff_stru[:l][sp1] = hash_1[sp1]
						end
						sp1_index += 1
						sp2_index += 1
					elsif sp1.l_count > sp2.l_count # 如果左边对比的简码比右边简码的级别低 e.g. L:1-2-1, R:1-2
						print_comparsion sp1, nil, hash_1[sp1], nil if r_print
						diff_stru[:l][sp1] = hash_1[sp1]
						sp1_index += 1
					elsif sp1.l_count < sp2.l_count# 如果左边对比的简码比右边简码的级别高 e.g. L:1-2, R:1-2-1
						print_comparsion nil, sp2, nil, hash_2[sp2] if r_print
						diff_stru[:r][sp2] = hash_2[sp2]
						sp2_index += 1
					end
				end
				print_comparsion if r_print # 画边界

				# puts "========== 给所有div加上简码class (sp1) ==========="
				# puts arr_sp1.map.with_index{|s, i|{(i)=>s}}.inject(""){|result, n|result += "$('div:eq(#{n.keys.first})').addClass(\"little_k_#{n.values.first}\");"}
				# puts "========== 给所有div加上简码class (sp2) ==========="
				# puts arr_sp2.map.with_index{|s, i|{(i)=>s}}.inject(""){|result, n|result += "$('div:eq(#{n.keys.first})').addClass(\"little_k_#{n.values.first}\");"}
				print "Done.\n"
				@report.output_to_file if r_print
				@diff_hash = diff_stru
				# return commen_stru, diff_stru
			end

			def print_diff_to_page hash
				parent_level = {}
				hash[:l].each do |div|
					sp = div[0]
					dom_class = div[1]
					parent_level[sp] = dom_class unless parent_level.keys.include_parent_level?(sp)
					if sub_sp = sp.is_someones_parent_level(parent_level)
						parent_level.delete(sub_sp)
						parent_level[sp] = dom_class
					end
				end

				puts "========== 给所有相异的加上简码角标 and 给所有相异的div背景标黄 ==========="
				puts parent_level.inject(""){|result, n| result += get_jquery_bc_yellow_and_corner_mark(n) }

				parent_level
			end

			private
			# 格式化输出对比结果，逐行调用
			def print_comparsion stru_1=nil, stru_2=nil, class_1=nil, class_2=nil
				return if stru_1.nil? and stru_2.nil?
				if stru_1.nil?
					@report.add_next_sibling_to_last_tr "<tr class='diff'><td>-</td><td>#{stru_2}(#{class_2})</td></tr>"
				elsif stru_2.nil?
					@report.add_next_sibling_to_last_tr "<tr class='diff'><td>#{stru_1}(#{class_1})</td><td>-</td></tr>"
				elsif !class_1.eql? class_2
					@report.add_next_sibling_to_last_tr "<tr class='diff'><td>#{stru_1}(#{class_1})</td><td>#{stru_2}(#{class_2})</td></tr>"
				else
					@report.add_next_sibling_to_last_tr "<tr class='commen'><td>#{stru_1}(#{class_1})</td><td>#{stru_2}(#{class_2})</td></tr>"
				end
			end

			def get_jquery_bc_yellow_and_corner_mark arr
				sp = arr[0]
				dom_class = arr[1]
				return "" if dom_class.nil?
				class_arr = dom_class.split(" ")
				if class_arr.size > 1
					return class_arr.inject("") { |result, j| result += get_jquery_bc_yellow_and_corner_mark([sp, j]) }
				else
					return "$('.#{dom_class}').css('background-color','yellow');" + 
						"$('.#{dom_class}').append(\"<div style='background-color: red; position: absolute; right: 0;top:0;'>#{sp}</div>\");"
				end
			end
			# end
		end
	end
end
class String
	# 用于获得级别个数
	# e.g. 1-2-1-1 => 3
	def l_count
		self.scan(/-/).size
	end

	def add_sub_level_sp
		self + "-1"
	end

	def parent_level_sp
		return self[0..-3] if self[-2]=="-"
		return self[0..-4] if self[-3]=="-"
	end

	# Input e.g. 
	# "1".is_someones_parent_level {"1-1" => "nav", "1-2" => "nav-inner"} => "1-2"
	def is_someones_parent_level hash
		sub_sp = ""
		hash.select {|k, v|k.include?(self) and sub_sp=k}.size>0 && sub_sp
	end
end

class Array
	def include_parent_level? sp
		simple_arr = self.select{|i| i[0] == sp[0]}
		sp_level   = sp.split("-")
		sp_level.size.times do |i|
			return true if simple_arr.include?(sp_level.first(i+1).join("-"))
		end
		return false
	end
end
