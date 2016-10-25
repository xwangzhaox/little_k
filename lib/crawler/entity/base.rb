# base.rb
require 'crawler/db'
require 'crawler/db/sql'

module Crawler
	module Entity
		module Base
			include DB::SQL

			def db_get_page_category
				dbh = DB.Connection
				dbh.query(PAGE_CATEGORY).to_a
			end
		end
	end
end

class Hash
	["url", "stru_sp", "attrbutes"].each do |attr|
		define_method("get_#{attr}") do
			self.values[0].values[0][attr]
		end
	end
end