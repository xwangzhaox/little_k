# db_test.rb

ASSETS_DIR = File.expand_path File.join(File.dirname(__FILE__), '../lib')
$LOAD_PATH.unshift(ASSETS_DIR)

require 'crawler/db'
require 'crawler/db/sql'

module Crawler
	class DBTest
		include DB::SQL

		def work
			dbh = DB.Connection
			dbh.query(SHOW_DATABAS).each do |row|
				puts row
			end
		end
	end
end
Crawler::DBTest.new.work