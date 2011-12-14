#!/usr/bin/perl
use TwitterUtil;
use Getopt::Long;

my %month = (
    "Jan" => 0,
    "Feb" => 1,
    "May" => 2,
    "Apr" => 3,
    "May" => 4,
    "Jun" => 5,
    "Jul" => 6,
    "Aug" => 7,
    "Sep" => 8,
    "Oct" => 9,
    "Nov" => 10,
    "Dec" => 11
    );


my $twitter = new  TwitterUtil();

my $screen_name="tksakaki";
my $pages=1;

GetOptions("screen_name=s" => \$screen_name,"pages=s" => \$pages);

if($screen_name ne "" && $pages > 0){
    
    for(my $page=1;$page<=$pages;$page++){
	my $result=$twitter->run_noauth("http://twitter.com/statuses/user_timeline/$screen_name.json?page=$page&count=20");
	
	foreach my $hash (@$result){
	    #textのみ表示
	    my %disp;
	    my $disp="";
	    $disp{site}=decode("utf8","ツイッター");
	    $disp{siteId}="twitter.com";
	    $disp{domain}="twitter";
	    
	    $$hash{"created_at"} =~
		/^(\S*) (\S*) (\d*) (\d*)\:(\d*)\:(\d*) \+0(\d)00 (\d*)/;
	    my $current=timelocal($6,$5,$4,$3,$month{$2},$8-1900)+(9-$7)*3600;
	    my ($sec,$min,$hour,$day,$mon,$year)=localtime($current);
	    
	    $disp{date}=sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$day,$hour,$min,$sec);
	    $disp{documentId} = $$hash{"id"};
	    my $user=$$hash{user};
	    $disp{authorId}=$user->{screen_name};

	    $disp{url} = "http://twitter.com/$$user{screen_name}/statuses/$$hash{id}"; 
	    $disp{body} = $$hash{text};

	    foreach my $key(keys %disp){
		$disp{$key}=&convert($disp{$key});

	    }
	    print encode("utf8","$disp{documentId},$disp{authorId},$disp{date},$disp{url},$disp{body}\n");

	}
    }
}


sub convert
{
    my ($word)=@_;

    $word =~ s/\&/\&amp\;/gs;
    $word =~ s/</\&lt\;/gs;
    $word =~ s/>/\&gt\;/gs;
    $word =~ s/\"/\&quot\;/gs;
    $word =~ s/\'/\&apos\;/gs;
    $word =~ s/[\r\n]/ /gs;
    $word =~s /,//gs;

    return $word;
}
