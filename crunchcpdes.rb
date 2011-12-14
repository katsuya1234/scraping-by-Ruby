###### Parse JSON file in Ruby an Insert into MySQL
# encoding: utf-8 
require 'open-uri'
require 'json'
require 'mysql'

###### Get Company name 
@a = Array.new()
db = Mysql::new("localhost","root","","companyapp_development")
company = db.query "select * from crunchdb_companylist"

# stmt = db.prepare " Insert into crunchbase_companylist(name2,permalink) values(?,?)"
# @c.each do |test|
#  stmt.execute test["name"],test["permalink"]
# end

#table = db.prepare "Insert into crunchdb_companyinfo(name,permalink,crunchbase_url,homepage_url,founded_year,founded_month,founded_day,offices,category_code,tag_list,email_address,phone_number,description,overview,created_at,updated_at) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"      



 table = db.prepare "Insert into crunchdb_companyinfo(name,permalink,crunchbase_url,homepage_url,founded_year,founded_month,founded_day,offices,category_code,tag_list,email_address,phone_number,description,overview,created_at,updated_at,ipo,total_money_raised,acquisition,acquisitions,funding_rounds,investments,competitions,relathinships,products,providerships,external_links,screenshots) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"

company.each do |test|
  @a = test[1]  
  begin
    open("http://api.crunchbase.com/v/1/company/#@a.js") do |f|
    @b = f.read
    end

    @c = JSON.parse @b    

    @offices = JSON.generate(@c["offices"])  
    @products = JSON.generate(@c["products"])
    @relationships = JSON.generate(@c["relationships"])
    @competitions = JSON.generate(@c["competitions"])
    @providerships = JSON.generate(@c["providerships"])
    @funding_rounds = JSON.generate(@c["funding_rounds"])
    @investments = JSON.generate(@c["investments"])
    @acquisitions = JSON.generate(@c["acquisitions"])
    @screenshots = JSON.generate(@c["screenshots"])
    @external_links = JSON.generate(@c["external_links"])
    @acquisition = JSON.generate(@c["acquisition"].to_a)
    @ipo = JSON.generate(@c["ipo"].to_a)

    
   table.execute @c["name"],@c["permalink"],@c["crunchbase_url"],@c["homepage_url"],@c["founded_year"],@c["founded_month"],@c["founded_day"],@offices,@c["category_code"],@c["tag_list"],@c["email_address"],@c["phone_number"],@c["description"],@c["overview"],@c["created_at"],@c["updated_at"],@ipo,@c["total_money_raised"],@acquisition,@acquisitions,@funding_rounds,@investments,@competitions,@relationships,@products,@providerships,@external_links,@screenshots
    

#  table.execute  @c["name"],@c["permalink"],@c["crunchbase_url"],@c["homepage_url"],@c["founded_year"],@c["founded_month"],@c["founded_day"],@offices,@c["category_code"],@c["tag_list"],@c["email_address"],@c["phone_number"],@c["description"],@c["overview"],@c["created_at"],@c["updated_at"]  

  print  @c["permalink"]

  rescue Exception

  end

end

  
