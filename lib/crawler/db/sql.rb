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
		end
	end
end