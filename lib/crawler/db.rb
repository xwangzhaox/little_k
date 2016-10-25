# db.rb

require 'crawler/db/connection'

module Crawler
	module DB

		class << self

			def Connection
				Connection.new
			end
		end
	end
end