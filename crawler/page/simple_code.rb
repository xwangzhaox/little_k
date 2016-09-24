# simple_code.rb

module Crawler
	module Page
		class SimpleCode
			
			def initialize(options)
				temp_file = File.open("./crawler/out_put_temp/page_diff.html", "r")
				@report = Nokogiri::HTML::DocumentFragment.parse temp_file.readlines.join.gsub(/\n|\r/, "")
				@report.at_css(".first_url").content = options
				@page = Nokogiri::HTML(open(options)).css('body')
			end

			# 递归扫描HTML文件结构, 获取网页结构简码
			def scan_html_structrue element=@page, parent_sp = nil
				i = 1
				hash = {}
				element.children.each do |e|
					# next unless e.name == "div"
					next if ["script", "noscript", "style", "comment"].include? e.name
					sp = parent_sp.nil? ? 
						i.to_s : (parent_sp + "-" + i.to_s)
					hash[sp] = {:name => e.name, :class => e.get_attribute('class')}#, :content => e.content} # "#{e.name}.#{e.get_attribute('class')}"
					i += 1
					# 递归处理
					hash = hash.merge scan_html_structrue e, sp
				end
				return hash
			end

			# 输入两个文件，返回他们相异的部分结构简码，判断是否要返回完整相同部分结构简码
			def comparsion_page f2, r_print = true
				@report.at_css(".second_url").content = f2
				f2 = Nokogiri::HTML(open(f2)).css('body')
				print "Scan page1 structrue ......"
				hash_1 = self.scan_html_structrue
				print " Done.\nScan page2 structrue ...... "
				hash_2 = scan_html_structrue f2
				print "Done.\n"
				arr_sp1 = hash_1.keys
				arr_sp2 = hash_2.keys

				commen_stru = {}
				diff_stru = { :l => {}, :r => {} }

				sp1_index = sp2_index = 0 # 输出两个结构的不同点
				print_comparsion if r_print # 画边界
				print "Compare pages ...... "
				loop do
					# 如果连个数组都遍历结束就结束循环
					break if sp1_index >= arr_sp1.size and sp2_index >= arr_sp2.size

					if arr_sp1[sp1_index] == arr_sp2[sp2_index]  # 如果结构简码相同，记录到 commen_stru 里
						print_comparsion arr_sp1[sp1_index], arr_sp2[sp2_index], hash_1[arr_sp1[sp1_index]], hash_2[arr_sp2[sp2_index]] if r_print
						commen_stru[arr_sp1[sp1_index]] = [hash_1[arr_sp1[sp1_index]], hash_2[arr_sp2[sp2_index]]]
						sp1_index += 1
						sp2_index += 1
					elsif arr_sp1[sp1_index].nil? or arr_sp2[sp2_index].nil?  # 如果一个结构简码数组遍历结束，剩余部分按照不同
						if arr_sp1[sp1_index].nil?
							print_comparsion nil, arr_sp2[sp2_index], nil, hash_2[arr_sp2[sp2_index]] if r_print
							diff_stru[:r][arr_sp2[sp2_index]] = hash_2[arr_sp2[sp2_index]]
						else
							print_comparsion arr_sp1[sp1_index], nil, hash_1[arr_sp1[sp1_index]], nil if r_print
							diff_stru[:l][arr_sp1[sp1_index]] = hash_1[arr_sp1[sp1_index]]
						end
						sp1_index += 1
						sp2_index += 1
					elsif arr_sp1[sp1_index].l_count > arr_sp2[sp2_index].l_count # 如果左边对比的简码比右边简码的级别低 e.g. L:1-2-1, R:1-2
						print_comparsion arr_sp1[sp1_index], nil, hash_1[arr_sp1[sp1_index]], nil if r_print
						diff_stru[:l][arr_sp1[sp1_index]] = hash_1[arr_sp1[sp1_index]]
						sp1_index += 1
					elsif arr_sp1[sp1_index].l_count < arr_sp2[sp2_index].l_count# 如果左边对比的简码比右边简码的级别高 e.g. L:1-2, R:1-2-1
						print_comparsion nil, arr_sp2[sp2_index], nil, hash_2[arr_sp2[sp2_index]] if r_print
						diff_stru[:r][arr_sp2[sp2_index]] = hash_2[arr_sp2[sp2_index]]
						sp2_index += 1
					end
				end
				print_comparsion if r_print # 画边界

				# puts "========== 给所有div加上简码class (sp1) ==========="
				# puts arr_sp1.map.with_index{|s, i|{(i)=>s}}.inject(""){|result, n|result += "$('div:eq(#{n.keys.first})').addClass(\"little_k_#{n.values.first}\");"}
				# puts "========== 给所有div加上简码class (sp2) ==========="
				# puts arr_sp2.map.with_index{|s, i|{(i)=>s}}.inject(""){|result, n|result += "$('div:eq(#{n.keys.first})').addClass(\"little_k_#{n.values.first}\");"}
				print "Done.\n"
				output_report_file
				return commen_stru, diff_stru
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
				next if stru_1.nil? and stru_2.nil?
				if stru_1.nil?
					@report.css("tr").last.add_next_sibling "<tr class='diff'><td>-</td><td>#{stru_2}(#{class_2})</td></tr>"
				elsif stru_2.nil?
					@report.css("tr").last.add_next_sibling "<tr class='diff'><td>#{stru_1}(#{class_1})</td><td>-</td></tr>"
				else
					@report.css("tr").last.add_next_sibling "<tr class='commen'><td>#{stru_1}(#{class_1})</td><td>#{stru_2}(#{class_2})</td></tr>"
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

			def output_report_file
				i = 1
				Dir.foreach("./crawler/") do |filename|
					i = filename.split("_").last.to_i + 1 if filename.include?("page_diff_report")
				end
				File.open("./crawler/page_diff_report_#{i}.html", "w"){|file|file.write @report.to_html}
				puts "Create file ...... crawler/page_diff_report_#{i}.html"
				`open ./crawler/page_diff_report_#{i}.html`
			end
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
