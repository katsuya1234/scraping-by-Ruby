

require 'open-uri'
require 'json/pure'

@a = Array.new()
open("http://api.crunchbase.com/v/1/people.js") do |f|
@b = JSON.generate(f)
end

print @b.class
print @b



