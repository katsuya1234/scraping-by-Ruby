use strict;
use LWP::UserAgent;
use JSON;
use Encode;
use utf8;
use strict;
use Time::Local;
use Net::OAuth;
use URI;
use Time::HiRes qw(sleep);


package TwitterUtil;

#以下を自分のApplication用に書き換えてください。（Search APIの場合は空でもOK）
our $AccessToken="66922542-yuIbgxPQKWqE4JhkP7kRfoKQtND4ekdRttL4hng8M";
our $AccessTokenSecret="rjSlKjAgFLg5AUiPIqm16bivVCdVrlR6coo3FWsYcw";
our $ConsumerKey="gKySNOYoRE3eVc1BM1M9dA";
our $ConsumerSecret="pm0LkXrAdYP9lVJGOcMIM5F08pZm3JmtNdRK6VEow";
  

sub new{
    my $pkg = shift;
    bless{
	url => undef,
	result => undef
    }, $pkg;
}

sub run_auth{
    my $result;
    my $pkg = shift;
    my $request_url = shift;

    my $consumer = Net::OAuth->request("protected resource")->new(
	consumer_key => $ConsumerKey,
	consumer_secret => $ConsumerSecret,
	request_url=> $request_url,
	request_method => 'GET',
	signature_method => 'HMAC-SHA1',
	timestamp => time,
	nonce => 'asdfkasdfwerwsg',
	token => $AccessToken,
	token_secret => $AccessTokenSecret
	);
    
    $consumer->sign;
    sleep(0.2);

    my $ua = LWP::UserAgent->new;

    my $result = $ua->get($consumer->to_url);
    #sleep(3);
    my $res = $result->content;
    my $errorCode=&errorCheckTwitter($res);
    
    #print STDERR "$res\n";
    #print "ERROR:$errorCode\n";
    if($errorCode == 200){	
	$result=JSON::from_json($res);
    }else{
	$result=$errorCode;
    }
    return $result;
    
}

sub run_noauth{
    my $result;
    my $pkg = shift;
    my $request_url = shift;
    my $rawflag = shift;

    my $consumer = Net::OAuth->request("protected resource")->new(
	consumer_key => $ConsumerKey,
	consumer_secret => $ConsumerSecret,
	request_url=> $request_url,
	request_method => 'GET',
	signature_method => 'HMAC-SHA1',
	timestamp => time,
	nonce => 'asdfkasdfwerwsg',
	token => $AccessToken,
	token_secret => $AccessTokenSecret
	);
    
    $consumer->sign;
    sleep(0.2);
    my $hdr = HTTP::Headers->new('User-Agent' => "Nijitter");
    my $req = HTTP::Request->new('GET' => $request_url,$hdr);

    my $ua = LWP::UserAgent->new;
    my $res = $ua->request($req)->content; 

    my $errorCode=&errorCheckTwitter($res);
    
    #print STDERR "$res\n";
    #print "ERROR:$errorCode\n";
    if($errorCode == 200){	
	if($rawflag != 1){
	    $result=JSON::from_json($res);
	}else{
	    $result = $res;
	}
    }else{
	$result=$errorCode;
    }
    return $result;
    
}


sub convertDate
{
    my %month = (
        "Jan" => 0,
        "Feb" => 1,
        "Mar" => 2,
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
    my ($date_exp)=@_;
    my ($result_date,$result_time);


    if($date_exp =~
       /^(\S*), (\d{2}) (\S*) (\d{4}) (\d*)\:(\d*)\:(\d*) \+0(\d)00/){
        $result_time = Time::Local::timelocal($7,$6,$5,$2,$month{$3},$4-1900)+(9-$8)*3600;
        my ($sec,$min,$hour,$day,$mon,$year)=localtime($result_time);

        $result_date=sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$day,$hour,$min,$sec);
    }elsif($date_exp =~ /^(\S+) (\S+) (\d{2}) (\d*)\:(\d*)\:(\d*) \+0(\d)00 (\d{4})/){
        $result_time = Time::Local::timelocal($6,$5,$4,$3,$month{$2},$8-1900)+(9-$7)*3600;
        my ($sec,$min,$hour,$day,$mon,$year)=localtime($result_time);

        $result_date=sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year+1900,$mon+1,$day,$hour,$min,$sec);
    }

#Tue Dec 15 14:22:51 +0000 2009

#    print "$date_exp\t$result_date\n";
    return ($result_date,$result_time);

}


sub errorCheckTwitter
{
    my ($result)=@_;
    my $errorCode=200;
    if($result =~ /<head>/ && $result =~ /Error/){
        $errorCode=500;
    }elsif($result =~ /^500/){
        $errorCode=500;
    }elsif($result =~ /\"error/){
        my $errors=JSON::from_json($result);
        if(defined $errors->{"error"}){
            $errorCode=99;
        }elsif(defined $errors->{"errors"}){
            $errorCode= $errors->{"errors"}[0]->{code};
        }
        #print "RUN JSON\n";
    }
    return $errorCode;
}

return 1;
