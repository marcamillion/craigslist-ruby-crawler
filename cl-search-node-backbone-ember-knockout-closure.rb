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

node_gigs_path = "output/client-side/node-gigs-#{today}.html"
backbone_gigs_path = "output/client-side/backbone-gigs-#{today}.html"
ember_gigs_path = "output/client-side/ember-gigs-#{today}.html"
knockout_gigs_path = "output/client-side/knockout-gigs-#{today}.html"
closure_gigs_path = "output/client-side/closure-gigs-#{today}.html"

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

node_gigs = []

posts.each do |i|
	if i[1] =~ /node|(node js)|(node.js)|(node framework)|(node js framework)|(node mvc)/i
		node_gigs << i
	end
end

backbone_gigs = []

posts.each do |i|
	if i[1] =~ /backbone|(backbone js)|(backbone.js)|(back bone)|(backbone mvc)/i
		backbone_gigs << i
	end
end

knockout_gigs = []

posts.each do |i|
	if i[1] =~ /knockout|(knockout.js)|(knock out js)|(knockout js)|(knockout js mvc)|(knockout mvc)|(knockout.js mvc)/i
		knockout_gigs << i
	end
end

ember_gigs = []

posts.each do |i|
	if i[1] =~ /ember|(ember js)|(ember.js)|(ember js mvc)|(ember.js mvc)/i
		ember_gigs << i
	end
end

closure_gigs = []

posts.each do |i|
	if i[1] =~ /closure|(google closure)|(gwt closure)|(closure js)|(closure.js)/i
		closure_gigs << i
	end
end

# This generates a basic - non-formatted - HTML file for all the Node specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{node_gigs.count} Node gigs in #{list.count} cities."				
	
			node_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(node_gigs_path))
File.open(node_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Backbone specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{backbone_gigs.count} Backbone gigs in #{list.count} cities."				
	
			backbone_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(backbone_gigs_path))
File.open(backbone_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Knockout specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{knockout_gigs.count} Knockout gigs in #{list.count} cities."				
	
			knockout_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(knockout_gigs_path))
File.open(knockout_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Ember specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{ember_gigs.count} Ember gigs in #{list.count} cities."				
	
			ember_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(ember_gigs_path))
File.open(ember_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Closure specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{closure_gigs.count} Closure gigs in #{list.count} cities."				
	
			closure_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(closure_gigs_path))
File.open(closure_gigs_path, 'w+') { |f| f.write(builder.to_html)  }