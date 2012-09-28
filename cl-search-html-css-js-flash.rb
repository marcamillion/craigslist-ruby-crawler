#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'fileutils'
require 'open-uri'
require 'date'
require 'pp'
require 'cgi'

# Specify date in format "Sept-26-2012"

today = Date.today.strftime("%b-%d-%Y")

html_gigs_path = "output/html-gigs-#{today}.html"
css_gigs_path = "output/css-gigs-#{today}.html"
javascript_gigs_path = "output/javascript-gigs-#{today}.html"
flash_gigs_path = "output/flash-gigs-#{today}.html"

url = 'http://www.craigslist.org/about/sites'

## The first step is to generate list of cities - since Craigslist doesn't provide this easily. 
## The second step is to then generate a secondary list of links specific to web dev gigs (which usually end in /cpg or /web).

def city_list(url)
	root = Nokogiri::HTML(open(url))
  list = root.css("a").map do |link|

		# This makes sure that we only store actual links, then stores the text & link for each valid link in an array.

      if link[:href] =~ /http/  
          [link.text, link[:href]]   
      end        
  end

	# This cleans up the array and gets rid of nil elements

	list = list.reject {|x| x.nil?}  
		
	## Here we have various sections of CL that we can search in for various gigs. 
	## If you wanted to see more software development stuff, you may search in /sof and /eng
	
		
	# list.map! {|f,l| [f, l + "/cpg/"]}
	# list.map! {|f,l| [f, l + "/web/"]}
	list.map! {|f,l| [f, l + "/web/", l + "/cpg/"]}	
	# list.map! {|f,l| [f, l + "/web/", l + "/cpg/", l + "/eng/", l + "/sof/", l + "/sad/"]}
	
end

list = city_list(url)

## Cleaning up the final list before iterating over it.

list.reject!(&:empty?)


first_items = list[0..700]

posts = []

## Here we will be parsing each of the valid links in the array and look for only pages with actual current gigs on them.
## Craigslist has some pages that have results from 'Nearby cities'. By specifying that we are looking for pages with an h4
## heading that contains the text of any day (Mon - Sun), we know that page has current, valid gigs and not duplicate gigs from nearby cities.

first_items.each do |i|	 
	i[1..-1].each do |link|
	    content_url = link
	    doc = Nokogiri::HTML(open(content_url))
			bq = doc.xpath('//blockquote')[1]
			
			date = nil
			bq.children.each do |node|
				date = node.text if node.name == "h4" && node.text =~ (/mon|tue|wed|thu|fri|sat|sun/i)
				next if !date
				next if node.name != "p"
				
				link = node.css('a').first['href']
				text = node.text
				date.gsub!(/Mon\s|Tue\s|Wed\s|Thu\s|Fri\s|Sat\s|Sun\s/i, "")
				
				posts << [date, text, link]			
			end
			
			posts.sort!.reverse!
			
		end
end

posts.reject!(&:empty?)

html_gigs = []

posts.each do |i|
	if i[1] =~ /html|html4|html5|(html 4)|(html 5)|xml/i
		html_gigs << i
	end
end

css_gigs = []

posts.each do |i|
	if i[1] =~ /css|css2|css3|(css 2)|(css 3)/i
		css_gigs << i
	end
end

flash_gigs = []

posts.each do |i|
	if i[1] =~ /flash|(flash 9)|(adobe flash)|(action script)|actionscript|(actionscript 3)|(actionscript-3)|(actionscript3)|(actionscript 2)|(action script 2)|swf|flex/i
		flash_gigs << i
	end
end

javascript_gigs = []

posts.each do |i|
	if i[1] =~ /javascript|js|jquery|prototype|(prototype js)/i
		javascript_gigs << i
	end
end

# This generates a basic - non-formatted - HTML file for all the HTML specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{html_gigs.count} HTML gigs in #{list.count} cities."				
	
			html_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(html_gigs_path))
File.open(html_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the CSS specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{css_gigs.count} CSS gigs in #{list.count} cities."				
	
			css_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(css_gigs_path))
File.open(css_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Flash specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{flash_gigs.count} Flash gigs in #{list.count} cities."				
	
			flash_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(flash_gigs_path))
File.open(flash_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Javascript specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{javascript_gigs.count} Javascript gigs in #{list.count} cities."				
	
			javascript_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(javascript_gigs_path))
File.open(javascript_gigs_path, 'w+') { |f| f.write(builder.to_html)  }