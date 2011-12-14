#!/usr/bin/perl
use strict;
use LWP::UserAgent;
use JSON;
use Encode;
use utf8;
use warnings;
use strict;
use Getopt::Long;
use DBI;
use TwitterUtil;
use GMAPUtil;
use sigtrap;

#
#Output:
# delimiter:\t
# tweet_id, username, userid, date, client, text

#
#perl searchTwitter_noPM.pl -q "twitter" -s 2009-12-01 -u 2009-12-15 -l all -p 1
#
#-q:query
#-s:since
#-u:until
#-l:language all, ja ,en etc.
#-p: page (1-100) 15 tweets/1 page


my $ua = LWP::UserAgent->new;

my $query = "twitter";
my $lang = "all";
my $since="";
my $unti="";
my $page=1;

my $tag="";
my $table="tweet";

GetOptions('query=s' => \$query, 'since=s' => \$since, 'until=s' => \$unti,
	  'language=s' => \$lang, 'page=s' => \$page, "tag=s" => \$tag, 
    'table=s' => \$table);

if($tag eq ""){
    $tag=$query;
}

my $db=DBI->connect("DBI:mysql:companyapp_development:localhost","root","ud0nud0n");
my $gmap = new GMAPUtil;


$page=1;
while($page <=15){
    eval{
	#コマンド呼び出し
	my $command = "q=$query&lang=$lang&page=$page&rpp=100";
	
	if($since ne ""){
	    if($since =~ /^\d{4}-\d{2}-\d{2}$/){
		$command .= "&since=$since";
	    }
	}
	if($unti ne ""){
	    if($unti =~ /^\d{4}-\d{2}-\d{2}$/){
		$command .= "&until=$unti";
	    }
	}
	
	
	
	my $req = HTTP::Request->new(GET => "http://search.twitter.com/search.json?$command");
	
	my $res = $ua->request($req)->content; 
	
	
	#結果表示
	if($res =~ /results/){
	    my $result=from_json($res);
	    #print "$res\n";
	    my $lists = $$result{results};
	    foreach my $hash (@$lists){
		my ($lat,$lon)=("","");
		my $loc_flag = 0;
		my $location="";
		if(defined $hash->{geo}){
		    $lat = $hash->{geo}->{coordinates}->[0];
		    $lon = $hash->{geo}->{coordinates}->[1];
		    $location =decode("utf8", $gmap->get_location_name($lat,$lon));
		    $loc_flag = 1;
		}
		my $text = encode('utf8', $$hash{text});
		$text =~ s/\r\n/ /gs;
		$text =~ s/\n/ /gs;
		$text =~ s/[\(\)]/ /gs;
		$text =~ s/[\'\"]//gs;
		#textのみ表示
#	    print "$$hash{created_at}\t$text\n";
		($$hash{created_at}) = TwitterUtil::convertDate($$hash{created_at});
		
		#Tweetの全情報表示
		my $sql;
		if($loc_flag == 0){
		    $sql = "INSERT INTO $table (`tweet_id`,`tweet_time`,`twitter_user`,`twitter_user_id`,`tweet_body`,`latitudes`,`longitudes`,`query`,`loc_flag`) VALUES (\'$$hash{id}\', \'$$hash{created_at}\', \'$$hash{from_user}\', \'$$hash{from_user_id}\', \'$text\',\'$lat\',\'$lon\',\'$tag\',\'$loc_flag\')";
		}else{
		    $sql = "INSERT INTO $table (`tweet_id`,`tweet_time`,`twitter_user`,`twitter_user_id`,`tweet_body`,`latitudes`,`longitudes`,`query`,`loc_flag`,`location`) VALUES (\'$$hash{id}\', \'$$hash{created_at}\', \'$$hash{from_user}\', \'$$hash{from_user_id}\', \'$text\',\'$lat\',\'$lon\',\'$tag\',\'$loc_flag\',\'$location\')";
		}
###	    print $sql,"\n";
#	    print "$$hash{id}\t$$hash{from_user}\t$$hash{from_user_id}\t$$hash{created_at}\t$$hash{source}\t$text\n";
		
		my $sth = $db->prepare($sql);
		my $result=$sth->execute|| 

# die $sth->errstr;
		$sth->finish;
	    } 
	}
    };
#$db->disconnect;
    
    if($@){
	print STDERR "ERROR:",$@,"\n";
	last;
	$page=16;
    }
    $page++;
}
