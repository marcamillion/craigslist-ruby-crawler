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

ios_gigs_path = "output/mobile/#{today}/ios-gigs-#{today}.html"
android_gigs_path = "output/mobile/#{today}/android-gigs-#{today}.html"
sencha_gigs_path = "output/mobile/#{today}/sencha-gigs-#{today}.html"
phonegap_gigs_path = "output/mobile/#{today}/phonegap-gigs-#{today}.html"

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

def get_city(url)
	uri = URI.parse(url)
	uri.host.split('.').first
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
			bq.children.each do |ios|
				date = ios.text if ios.name == "h4" && ios.text =~ (/mon|tue|wed|thu|fri|sat|sun/i)
				next if !date
				next if ios.name != "p"
				
				link = ios.css('a').first['href']
				text = ios.text
				date.gsub!(/Mon\s|Tue\s|Wed\s|Thu\s|Fri\s|Sat\s|Sun\s/i, "")
				
				posts << [date, text, link]			
			end
			
			posts.sort!.reverse!
			
		end
end

posts.reject!(&:empty?)

ios_gigs = []
ios_cities = []

posts.each do |i|
	if i[1] =~ /ios|iphone|(iphone 3)|(iphone 4)|(iphone 4s)|(iphone 5)|(iphone4s)|(iphone4)|(iphone5)|(iphone OS)|(iphoneos)|(ios4)|(ios5)|(ios6)|(ios 4)|(ios 5)|(ios 6)|(xcode)|(x code)|(xcode4)|(xcode 4)|(x code 4)|(xcode 4.5)|(x code 4.5)|(xcode 4.5)|(objective-c)|(objective c)|(objectivec)|(iphone app)|(ipad app)|(ipod)|(ipod touch)|(ipad)/i
		ios_gigs << i
		ios_cities << [get_city(i[2]), "ios"]						
	end
end

a_cities = ios_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}


android_gigs = []
android_cities = []

posts.each do |i|
	if i[1] =~ /android|(android os)|(google android)|(android1.5)|(android 1.5)|(android 1.5 cupcake)|(android cupcake)|(cupcake)|(android 1.6)|(android1.6)|(android donut)|(android 1.6 donut)|(android2.3)|(android 2.3)|(android 2.3 gingerbread)|(android gingerbread)|(gingerbread)|(android 3 honeycomb)|(android3 honeycomb)|(honeycomb)|(android honeycomb)|(android honey comb)|(android3)|(android 3)|(android 3.1)|(android 3.2)|(android3.1)|(android3.2)|android4|(android 4)|(android 4 icecream sandwich)|(android 4 ice cream sandwich)|(android 4 ice cream sandwhich)|(android ice cream sandwich)|(android icecream sandwich)|(android ice cream)|(android icecream)|(android4.1)|(android 4.1)|(android 4.1 jelly bean)|(android jelly bean)|(android jellybean)|(android4.1 jellybean)|(android app)|(nexus)|(google nexus)|(samsung galaxy)|(galaxy app)/i
		android_gigs << i
		android_cities << [get_city(i[2]), "android"]								
	end
end

b_cities = android_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}


sencha_gigs = []
sencha_cities = []

posts.each do |i|
	if i[1] =~ /sencha|(sencha-touch)|(sencha touch)|(sencha touch 2)|(sencha-touch-2)|(sencha-touch 2)|(html5 mobile app)|(html5 native mobile app)/i
		sencha_gigs << i
		sencha_cities << [get_city(i[2]), "sencha"]										
	end
end

c_cities = sencha_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}


phonegap_gigs = []
phonegap_cities = []

posts.each do |i|
	if i[1] =~ /phonegap|(phone gap)|(adobe phonegap)|(adobe phone gap)|(cross platform mobile app)/i
		phonegap_gigs << i
		phonegap_cities << [get_city(i[2]), "phonegap"]												
	end
end

d_cities = phonegap_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}


# This generates a basic - non-formatted - HTML file for all the Node specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{ios_gigs.count} iOS gigs in #{list.count} cities."				
				a_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end
	
			ios_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(ios_gigs_path))
File.open(ios_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Backbone specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{android_gigs.count} Android gigs in #{list.count} cities."				
				b_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end
	
			android_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(android_gigs_path))
File.open(android_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Sencha specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{sencha_gigs.count} Sencha gigs in #{list.count} cities."				
				c_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end
	
			sencha_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(sencha_gigs_path))
File.open(sencha_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Phonegap specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "Out of #{posts.count} gigs examined, there are #{phonegap_gigs.count} Phonegap gigs in #{list.count} cities."				
				d_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end
	
			phonegap_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

FileUtils.mkdir_p(File.dirname(phonegap_gigs_path))
File.open(phonegap_gigs_path, 'w+') { |f| f.write(builder.to_html)  }