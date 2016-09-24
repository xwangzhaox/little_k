# report.rb

module Crawler
	module Page
		class Report
			def initialize(options)
				temp_file = File.open("./crawler/out_put_temp/#{options}", "r")
				@report   = Nokogiri::HTML::DocumentFragment.parse temp_file.readlines.join.gsub(/\n|\r/, "")
			end

			def first_url=url
				@report.at_css(".first_url").content = url
			end

			def second_url=url
				@report.at_css(".second_url").content = url
			end

			def add_next_sibling_to_last_tr element
				@report.css("tr").last.add_next_sibling element
			end

			def to_html
				@report.to_html
			end
		end
	end
end