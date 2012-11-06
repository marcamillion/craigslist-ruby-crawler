#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'pp'
require 'cgi'
# require 'letters'

# Specify date in format "Sept-26-2012"

today = Date.today.strftime("%b-%d-%Y")

rails_gigs_path = "rails-gigs-#{today}.html"
ruby_gigs_path = "ruby-gigs-#{today}.html"
django_gigs_path = "django-gigs-#{today}.html"
python_gigs_path = "python-gigs-#{today}.html"
php_gigs_path = "php-gigs-#{today}.html"
codeigniter_gigs_path = "codeigniter-gigs-#{today}.html"

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

rails_gigs = []
rails_cities = []

posts.each do |i|
	if i[1] =~ /rails|(ruby on rails)|(ruby on rails 3)|(rails 3)|(rails 2)/i
		rails_gigs << i
		rails_cities << [get_city(i[2]), "rails"]		
	end
end

a_cities = rails_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}

ruby_gigs = []
ruby_cities = []

posts.each do |i|
	if i[1] =~ /ruby|(ruby 1.8.7)|(ruby 1.9.2)|(ruby 1.9.3)|ruby187|ruby192|ruby193/i
		ruby_gigs << i
		ruby_cities << [get_city(i[2]), "ruby"]		
	end
end

b_cities = ruby_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}

python_gigs = []
python_cities = []

posts.each do |i|
	if i[1] =~ /python|(python 3)|(python 2.7)|python3|python2/i
		python_gigs << i
		python_cities << [get_city(i[2]), "python"]		
	end
end

c_cities = python_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}

django_gigs = []
django_cities = []

posts.each do |i|
	if i[1] =~ /django/i
		django_gigs << i
		django_cities << [get_city(i[2]), "django"]				
	end
end

d_cities = django_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}

php_gigs = []
php_cities = []

posts.each do |i|
	if i[1] =~ /php|(php 5)|(php5)|php4|(php 4)/i
		php_gigs << i
		php_cities << [get_city(i[2]), "php"]				
	end
end

e_cities = php_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}

codeigniter_gigs = []
codeigniter_cities = []

posts.each do |i|
	if i[1] =~ /(code igniter)|codeigniter|(code igniter 2)|(codeigniter 2)|(codeigniter2)/i
		codeigniter_gigs << i
		codeigniter_cities << [get_city(i[2]), "codeigniter"]				
	end
end

f_cities = codeigniter_cities.group_by{ |x| x[0]}.map{ |k,v| [k, v.size]}



# This generates a basic - non-formatted - HTML file for all the Rails specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
			doc.text "There are #{rails_gigs.count} Rails gigs."
			a_cities.each do |city|
				doc.p {
					doc.text "#{city[0]}: #{city[1]} posts"
				}								
			end

			rails_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

File.open(rails_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Ruby specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "There are #{ruby_gigs.count} Ruby gigs."				
				b_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end	
			ruby_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

File.open(ruby_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Python specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "There are #{python_gigs.count} Python gigs."				
				c_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end
		
			python_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

File.open(python_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Django specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "There are #{django_gigs.count} Django gigs."				
				d_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end
	
			django_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

File.open(django_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the PHP specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "There are #{php_gigs.count} PHP gigs."				
				e_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end
	
			php_gigs.each do |job|
					doc.p {
						# doc.text job
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

File.open(php_gigs_path, 'w+') { |f| f.write(builder.to_html)  }

# This generates a basic - non-formatted - HTML file for all the Code Igniter specific gigs in all the cities

builder = Nokogiri::HTML::Builder.new do |doc|
	doc.html {
		doc.body {
				doc.text "There are #{codeigniter_gigs.count} CodeIgniter gigs."				
				f_cities.each do |city|
					doc.p {
						doc.text "#{city[0]}: #{city[1]} posts"
					}								
				end
	
			codeigniter_gigs.each do |job|
					doc.p {
						doc.text job[0]
						doc.a job[1], :href => job[2]
					}			
			end
			}			
		}
end

File.open(codeigniter_gigs_path, 'w+') { |f| f.write(builder.to_html)  }