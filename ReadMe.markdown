# Craigslist Ruby Keyword Crawler

This Ruby script, generally speaking, allows you to crawl Craigslist (throughout most cities around the world listed on CL) and parse the results for specific keywords you are looking for. Upon completion, it spits out the results to an HTML file in a directory called 'output'.

## Run Time

The run time, if you run it with the default values, can be anywhere from 1000 - 4,500 seconds (i.e. 16 minutes to 1.25 hrs).

## Getting it Running Responsibly

To verify that it works on your machine, or in your environment, any at all - you may want to reduce the amount of items parsed to
say `10`, down from `701`, by modifying the line:

Original:

```` 
first_items = list[0..700]
````
To:

````
first_items = list[10..20]
````
If it runs with no issues, you are free to increase it back to the original numbers.

Note that your ISP may object to you repeatedly running a crawler from your home internet connection. So if they come a knocking, I am not responsible.

## Modifying Keywords

The master array that stores all the 'useful' links is called `posts`. By useful I mean the links that correspond to the gigs found that have your specified keywords.

To change the keywords that are searched, you will want to look for the lines:
````
posts.each do |i|
  if i[1] =~ /keyword|(some keyword combo)/i
    some_array << i
  end
end
````
Although I am sure you are aware, the `=~` operator is a regular expression operator.

To read about how Ruby handles and this operator, check out the [RegExp docs here](http://www.ruby-doc.org/core-1.9.3/Regexp.html).

The HTML generation is handled by [Nokogiri](http://nokogiri.org/). 

## Additional Files

I have included some sample output HTML files in their respective directories.

## Left to do

* This is a pretty crude script, that is not very DRY. So generally DRYing it up. 
* Increase efficiency - so script runs in less time.
* Re-factor to make adding keywords for multiple languages easier than duplicating a ton of code.
* Parse and store cities examined - along with the keywords in those cities (ideally, it would be good if we could answer the question "How many Rails posts in Chicago?")
* Adding tests