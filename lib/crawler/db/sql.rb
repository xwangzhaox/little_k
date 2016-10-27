# sql.rb

module Crawler
	module DB
		module SQL
			SHOW_DATABAS = <<-EOS
show databases;
EOS

			PAGE_CATEGORY = <<-EOS
select * from page_category;
EOS

			ATTRIBUTES_MAX_ID= <<-EOS
select max(id) from attributes;
EOS

			def sql_insert_page_category url, stru_sp
				raise "(PageCategory:) Insert data could not be blank!" if url == "" or stru_sp == ""
				"INSERT INTO page_category (url_base, stru_sp) VALUES(\"#{url}\", \"#{stru_sp}\"); "
			end

			def sql_confirm_attribute_exist str
				"select * from attributes where name in (\"#{str}\");"
			end

			def sql_insert_attributes attr = []
				raise "(Attributes:) Insert data could not be blank!" if attr.empty?
				str = attr.select{|item|item[:id].nil?}.map{|n|"\"#{n[:name]}\""}.join("),(")
				return nil if str==""
				"INSERT INTO attributes (name) VALUES (#{str}); "
			end

			def sql_insert_pc_attr attr, page_category_id
				str = attr.map{|x|"#{page_category_id}, \"#{x[:id]}\", \"#{x[:path]}\", true, null, true, true"}.join("),(")
				"INSERT INTO pc_attr (page_category_id, attribute_id, xpath, indication_find, regular, confirmed, tracking) VALUES(#{str}); "
			end

			def sql_insert_page page_category_id, page_type, url, title, description, content
				"INSERT INTO page (page_category_id, page_type, tracking_at, url, title, description, content) VALUES (#{page_category_id}, #{page_type}, NOW(), \"#{url}\", \"#{title}\", \"#{description}\", \"#{content}\");"
			end

			def sql_insert_page_attr page_id, pc_attr_id, value
				"INSERT INTO page_attr (page_id, attr_id, value, tracking_at) VALUES (#{page_id}, #{pc_attr_id}, \"#{value}\", NOW());"
			end
		end
	end
end