#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'date'
require 'pp'
require 'cgi'

# Specify date in format "Sept-26-2012"

today = Date.today.strftime("%b-%d-%Y")

java_gigs_path = "output/server-side/java-gigs-#{today}.html"
perl_gigs_path = "output/server-side/perl-gigs-#{today}.html"
dot_net_gigs_path = "output/server-side/dot_net-gigs-#{today}.html"
lisp_gigs_path = "output/server-side/lisp-gigs-#{today}.html"
c_sharp_gigs_path = "output/server-side/c_sharp-gigs-#{today}.html"

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

## Here we will be parsing each of the valid cities in the array and look for only pages with actual current gigs on them.
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

java_gigs = []

posts.each do |i|
	if i[1] =~ /java|jsp|(java-ee)|(java ee)|(java enterprise edition)|(java enterprise)|(java servlets)|(servlets)|(java jsp)/i
		java_gigs << i
	end
end

perl_gigs = []

posts.each do |i|
	if i[1] =~ /perl|(perl cgi)|(perl module)|cgi/i
		perl_gigs << i
	end
end

lisp_gigs = []

posts.each do |i|
	if i[1] =~ /lisp|(common lisp)|(common-lisp)|(scheme)|clojure/i
		lisp_gigs << i
	end
end

dot_net_gigs = []

posts.each do |i|
	if i[1] =~ /dotnet|(dot net)|(asp)|(asp.net)|(asp dot net)|(asp.net mvc)|(asp.net mvc 3)|(asp mvc)|(.net mvc)|(dot net mvc)|(dot net 4)|(.net 4)|(entity-framework)|(entity framework)/i
		dot_net_gigs << i
	end
end

c_sharp_gigs = []

posts.each do |i|
	if i[1] =~ /c#|(c#)|(c sharp)|(c-sharp)|(c-#)|(entity framework)|(entity-framework)|(vb.net)|(vb net)|(vb dot net)/i
		c_sharp_gigs << i
	end
end

# This generates a basic - non-formatted - HTML file for all the Java specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{java_gigs.count} Java gigs in #{list.count} cities."				
	
			java_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(java_gigs_path))
File.open(java_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Perl specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{perl_gigs.count} Perl gigs in #{list.count} cities."				
	
			perl_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(perl_gigs_path))
File.open(perl_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Lisp specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{lisp_gigs.count} Lisp gigs in #{list.count} cities."				
	
			lisp_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(lisp_gigs_path))
File.open(lisp_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Dot-Net specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{dot_net_gigs.count} Dot-Net gigs in #{list.count} cities."				
	
			dot_net_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(dot_net_gigs_path))
File.open(dot_net_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the C-Sharp specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{c_sharp_gigs.count} C-Sharp gigs in #{list.count} cities."				
	
			c_sharp_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(c_sharp_gigs_path))
File.open(c_sharp_gigs_path, 'w+') { |f| f.write(builder.to_html)  }