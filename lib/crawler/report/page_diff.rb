#encoding=UTF-8
# page_diff.rb

module Crawler
	module Report
		class PageDiff
			TEMPLATE_FILE = File.join(File.dirname("__FILE__"), "lib/crawler/report/templates/page_diff.html")
			FILE_NAME_BASE_PATH = File.join(File.dirname("__FILE__"), "lib/crawler/report/tmp")
			REPORT_FILE_NAME_BASE_PRE = "page_diff_report_"
			
			def initialize(options)
				temp_file = File.open(TEMPLATE_FILE, "r")
				@report   = Nokogiri::HTML::DocumentFragment.parse temp_file.readlines.join.gsub(/\n|\r/, "")
				self.first_url = options[:first_url]
			end

			def to_html
				@report.to_html
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

			def report_file_name
				@report_file_name.nil? ? 
					set_report_file_name :
					@report_file_name
			end

			def set_report_file_name
				i = 1
				Dir.foreach(FILE_NAME_BASE_PATH) do |filename|
					@report_file_name = filename.include?(REPORT_FILE_NAME_BASE_PRE) ? 
						(REPORT_FILE_NAME_BASE_PRE + (filename.split("_").last.to_i + 1).to_s + ".html") :
						(REPORT_FILE_NAME_BASE_PRE + "1.html")
				end
				@report_file_name
			end

			def output_to_file
				File.open(FILE_NAME_BASE_PATH + report_file_name, "w"){|file|file.write @report.to_html}
				puts "Create file ...... crawler/" + report_file_name
				`open #{FILE_NAME_BASE_PATH + report_file_name}`
			end
		end
	end
end