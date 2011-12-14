

###### Parse JSON file in Ruby an Insert into MySQL                                                                                                                                                       
# encoding: utf-8                                                                                                                                                                                         
require 'open-uri'
require 'json'
require 'mysql'

###### Get String file on the URL                                                                                                                                                                         
@a = Array.new()

open("http://api.crunchbase.com/v/1/people.js") do |f|
 @b = f.read
end

###### Parse into Ruby object                                                                                                                                                                             
 @c = JSON.parse @b


open("testfile.js") do |f|
  f.write @b
end 

#exit;

##### Parce  Hash.Array class                                                                                                                                                                             
# @c.each do |test|
#  print test["first_name"]
#  print test["last_name"]
#  puts test["permalink"]
# end


# exit;

##### Insert into MySQL                                                                                                                                                                                   
#db = Mysql::new("localhost","root","","companyapp_development")
# table = db.query("SELECT * from crunchbase_companylist limit 10")                                                                                                                                       
#stmt = db.prepare " Insert into crunchbase_peoplelist(first_name,last_name,permalink) values(?,?,?)"

# @c.each do |test|
#  stmt.execute test["first_name"],test["last_name"],test["permalink"]
#end
