# simple_code.rb

module Crawler
	module SimpleCode

		def initialize
			reset_base_val
		end

		# # 获取网页的结构简码(初始简码)
		# def get_single_page_stru_sp page, level = 0
		# 	scan_html_structrue page, level
		# 	return @s
		# end

		# 递归扫描HTML文件结构, 获取网页结构简码
		def scan_html_structrue element, parent_sp = nil
			i = 1
			hash = {}
			element.children.each do |e|
				next unless e.name == "div"
				sp = parent_sp.nil? ? 
					i.to_s : (parent_sp + "-" + i.to_s)
				hash[sp] = e.get_attribute("class")
				# binding.pry
				i += 1
				# 递归处理
				hash = hash.merge scan_html_structrue e, sp
			end
			return hash
		end

		# # 递归扫描HTML文件结构, 获取网页结构简码
		# def scan_html_structrue element, level
		# 	# 用于级别内累计div个数
		# 	@i << 1
		# 	# return if @i.size > 3
		# 	element.children.each do |e|
		# 		# 只记录div
		# 		next unless e.name == "div"
		# 		break if level != 0 and @i.size > level
		# 		@s += @i.join("-") + "\n"
		# 		# 递归处理
		# 		scan_html_structrue e, level
		# 	end
		# 	@i.pop
		# 	@i[-1] = @i[-1] + 1 unless @i.empty?
		# end

		# 输入两个文件，返回他们相异的部分结构简码，判断是否要返回完整相同部分结构简码
		def comparsion_page f1, f2, r_print = true
			hash_1 = scan_html_structrue f1
			hash_2 = scan_html_structrue f2
			arr_sp1 = hash_1.keys
			arr_sp2 = hash_2.keys

			commen_stru = {}
			diff_stru = { :l => {}, :r => {} }

			sp1_index = sp2_index = 0 # 输出两个结构的不同点
			print_comparsion if r_print # 画边界
			loop do
				# 如果连个数组都遍历结束就结束循环
				break if sp1_index >= arr_sp1.size and sp2_index >= arr_sp2.size

				if arr_sp1[sp1_index] == arr_sp2[sp2_index]  # 如果结构简码相同，记录到 commen_stru 里
					print_comparsion arr_sp1[sp1_index], arr_sp2[sp2_index] if r_print
					commen_stru[arr_sp1[sp1_index]] = [hash_1[arr_sp1[sp1_index]], hash_2[arr_sp2[sp2_index]]]
					sp1_index += 1
					sp2_index += 1
				elsif arr_sp1[sp1_index].nil? or arr_sp2[sp2_index].nil?  # 如果一个结构简码数组遍历结束，剩余部分按照不同
					if arr_sp1[sp1_index].nil?
						print_comparsion nil, arr_sp2[sp2_index] if r_print
						diff_stru[:r][arr_sp2[sp2_index]] = hash_2[arr_sp2[sp2_index]]
					else
						print_comparsion arr_sp1[sp1_index], nil if r_print
						diff_stru[:l][arr_sp1[sp1_index]] = hash_1[arr_sp1[sp1_index]]
					end
					sp1_index += 1
					sp2_index += 1
				elsif arr_sp1[sp1_index].l_count > arr_sp2[sp2_index].l_count # 如果左边对比的简码比右边简码的级别低 e.g. L:1-2-1, R:1-2
					print_comparsion arr_sp1[sp1_index], nil if r_print
					diff_stru[:l][arr_sp1[sp1_index]] = hash_1[arr_sp1[sp1_index]]
					sp1_index += 1
				elsif arr_sp1[sp1_index].l_count < arr_sp2[sp2_index].l_count# 如果左边对比的简码比右边简码的级别高 e.g. L:1-2, R:1-2-1
					print_comparsion nil, arr_sp2[sp2_index] if r_print
					diff_stru[:r][arr_sp2[sp2_index]] = hash_2[arr_sp2[sp2_index]]
					sp2_index += 1
				end
			end
			print_comparsion if r_print # 画边界

			puts "========== 给所有div加上简码class (sp1) ==========="
			puts arr_sp1.map.with_index{|s, i|{(i)=>s}}.inject(""){|result, n|result += "$('div:eq(#{n.keys.first})').addClass(\"little_k_#{n.values.first}\");"}
			puts "========== 给所有div加上简码class (sp2) ==========="
			puts arr_sp2.map.with_index{|s, i|{(i)=>s}}.inject(""){|result, n|result += "$('div:eq(#{n.keys.first})').addClass(\"little_k_#{n.values.first}\");"}

			return commen_stru, diff_stru
		end

		# # 输入两个文件，返回他们相异的部分结构简码，判断是否要返回完整相同部分结构简码
		# def comparsion_page f1, f2, r_print = true
		# 	arr_sp1 = get_single_page_stru_sp(f1).split("\n")
		# 	reset_base_val
		# 	arr_sp2 = get_single_page_stru_sp(f2).split("\n")
		# 	reset_base_val

		# 	commen_stru = {}
		# 	diff_stru = { :l => {}, :r => {} }

		# 	sp1_index = sp2_index = 0 # 输出两个结构的不同点
		# 	print_comparsion if r_print # 画边界
		# 	loop do
		# 		# 如果连个数组都遍历结束就结束循环
		# 		break if sp1_index >= arr_sp1.size and sp2_index >= arr_sp2.size

		# 		if arr_sp1[sp1_index] == arr_sp2[sp2_index]  # 如果结构简码相同，记录到 commen_stru 里
		# 			print_comparsion arr_sp1[sp1_index], arr_sp2[sp2_index] if r_print
		# 			commen_stru[arr_sp1[sp1_index]] = [sp1_index, sp2_index]
		# 			sp1_index += 1
		# 			sp2_index += 1
		# 		elsif arr_sp1[sp1_index].nil? or arr_sp2[sp2_index].nil?  # 如果一个结构简码数组遍历结束，剩余部分按照不同
		# 			if arr_sp1[sp1_index].nil?
		# 				print_comparsion nil, arr_sp2[sp2_index] if r_print
		# 				diff_stru[:r][sp2_index] = arr_sp2[sp2_index]
		# 			else
		# 				print_comparsion arr_sp1[sp1_index], nil if r_print
		# 				diff_stru[:l][sp1_index] = arr_sp1[sp1_index]
		# 			end
		# 			sp1_index += 1
		# 			sp2_index += 1
		# 		elsif arr_sp1[sp1_index].l_count > arr_sp2[sp2_index].l_count # 如果左边对比的简码比右边简码的级别低 e.g. L:1-2-1, R:1-2
		# 			print_comparsion arr_sp1[sp1_index], nil if r_print
		# 			diff_stru[:l][sp1_index] = arr_sp1[sp1_index]
		# 			sp1_index += 1
		# 		elsif arr_sp1[sp1_index].l_count < arr_sp2[sp2_index].l_count# 如果左边对比的简码比右边简码的级别高 e.g. L:1-2, R:1-2-1
		# 			print_comparsion nil, arr_sp2[sp2_index] if r_print
		# 			diff_stru[:r][sp2_index] = arr_sp2[sp2_index]
		# 			sp2_index += 1
		# 		end
		# 	end
		# 	print_comparsion if r_print # 画边界

		# 	puts "========== 给所有div加上简码class (sp1) ==========="
		# 	puts arr_sp1.map.with_index{|s, i|{(i)=>s}}.inject(""){|result, n|result += "$('div:eq(#{n.keys.first})').addClass(\"little_k_#{n.values.first}\");"}
		# 	puts "========== 给所有div加上简码class (sp2) ==========="
		# 	puts arr_sp2.map.with_index{|s, i|{(i)=>s}}.inject(""){|result, n|result += "$('div:eq(#{n.keys.first})').addClass(\"little_k_#{n.values.first}\");"}

		# 	return commen_stru, diff_stru
		# end

		def print_diff_to_page hash
			parent_level = {}
			hash[:l].each do |div|
				index = div[0]
				sp = div[1]
				parent_level[index] = sp unless parent_level.values.include_parent_level?(sp)
				if dindex = sp.is_someones_parent_level(parent_level)
					parent_level.delete(dindex)
					parent_level[index] = sp
				end
			end
			# puts "========== 给所有相异的div背景标黄 ==========="
			# puts parent_level.inject(""){|result, n|result += "$('div:eq(#{n[0]})').css('background-color','yellow'); "}[0..-3]
			# puts "========== 给所有相异的加上简码角标 ==========="
			# puts parent_level.inject(""){|result, n|result += "$('div:eq(#{n[0]})').append(\"<div style='background-color: red; position: absolute; right: 0;top:0;'>#{n[1]}</div>\");"}
			# parent_level
		end

		private
		# 格式化输出对比结果，逐行调用
		def print_comparsion stru_1=nil, stru_2=nil
			str_1 = stru_1.ljust(30) rescue "".ljust(30)
			str_2 = stru_2.ljust(30) rescue "".ljust(30)
			if stru_1.nil? and stru_2.nil? 
				puts "-".ljust(63, "-")
			elsif stru_1.nil?
				puts "| " + "-".ljust(30) + "| " + str_2 + "|"
			elsif stru_2.nil?
				puts "| " + str_1 + "| " + "-".ljust(30) + "|"
			else
				puts "| " + str_1 + "| " + str_2 + "|"
			end
		end

		# Reset value
		def reset_base_val
			@s = ""
			@i = []
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

	def is_someones_parent_level hash
		dindex = 0
		hash.select {|k, v|v.include?(self) and dindex=k}.size>0 && dindex
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