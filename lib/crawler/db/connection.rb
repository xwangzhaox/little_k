# connection.rb
require "mysql2"

module Crawler
	module DB
		class Connection
			HOST = "localhost"
			USER = "root"
			PASS = ""
			DATABASE = "crawler_dev"

			def initialize()
				begin
					@dbh = Mysql2::Client.new(
						:host     => HOST, # 主机
						:username => USER,      # 用户名
						:password => PASS,    # 密码
						:database => DATABASE,      # 数据库
						:encoding => 'utf8'       # 编码
						)
					puts "Server version: " + @dbh.info[:version]
				rescue Mysql2::Error => e
					print "Error code: ", e.errno, "/n"
					print "Error message: ", e.error, "/n"
				ensure
				end
			end

			def query(sql = "")
				puts "SQL could not be blank." if sql == ""
				result = @dbh.query(sql)
				printf "(DB:) #{sql}\n"
				printf "%d rows were inserted:\n", @dbh.affected_rows
				result
			end
		end
	end
end