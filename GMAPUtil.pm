package GMAPUtil;

use strict;
use warnings;
use Encode;
use Time::Local;
use LWP::Simple;
use XML::Simple;
use Encode::Guess qw(euc-jp shiftjis 7bit-jis);
use LWP::UserAgent;
use JSON;


sub new {
    my $pkg = shift;
    return bless {
        _debug => 0,
    }, $pkg;
}

## GoogleMapAPIを使って座標取得
sub get_latlon_gmap
{
    use utf8;
    my ($self,$addr) = @_;
    my ($lat,$lon)=(0,0);
    $addr = encode("utf8",$addr);
    #print "$addr\n";
    $addr =~ s/(\W)/'%'.unpack('H2',$1)/eg;
#    print "$addr\n";
    my $res = get("http://maps.google.co.jp/maps?q=$addr");
#    print $res;
    if($res =~ /var viewport_center_lat=([0-9\.]+);var viewport_center_lng=([0-9\.]+);/){
#    if($res =~ /offsetHeight},([0-9\.]+),([0-9\.]+),zoom/si){
	($lat,$lon) = ($1,$2);
	if($lat!=36.562600 and $lon!=136.362305){
#	    print "$lat:$lon\n";
	}else{
	    $lat=0;
	    $lon=0;
	}
    }
    
    return ($lat,$lon);
}

sub get_location_name
{
    use utf8;
    my ($self,$lat,$lon) = @_;
    my $place="";
    my $times=0;
    if($lat =~ /^[0-9\.]+$/ && $lon =~ /^[0-9\.]+$/){

	my $res = get("http://maps.google.com/maps/api/geocode/json?latlng=$lat,$lon&sensor=false&language=ja");
	while($res =~ /OVER_QUERY_LIMIT/){
	    sleep(5);
	    print STDERR "$times trial\n";
	    $res=get("http://maps.google.com/maps/api/geocode/json?latlng=$lat,$lon&sensor=false&language=ja");
	    if($times > 5){
		$times++;
		last;
	    }
	}
	if($res !~ /REQUEST_DENIED/ && $res ne ""){
	    my $result=JSON::from_json($res);
	    my $type = $result->{results}->[0]->{types}->[0];
	    my $level=0;
	    if($type =~ /sublocality_level/){
		my $list=$result->{results};
		my $nameFlag=0;
		foreach my $tag(@$list){
#		    print $tag->{types}->[0],"\n";;
		    if($tag->{types}->[0] eq "sublocality_level_2"){
			$place = $tag->{formatted_address};
			$nameFlag=1;
			last;
		    }
		}		
		if($nameFlag == 0){
		    $place = $$list[0]->{formatted_address};
		}

	    }else{
		$place = $result->{results}->[0]->{address_components}->[0]->{short_name};
	    }
	}
    }    
    return ($place);

}

sub get_location_name_old
{
    use utf8;
    my ($self,$lat,$lon) = @_;
    my $place="";

    if($lat =~ /^[0-9\.]+$/ && $lon =~ /^[0-9\.]+$/){
	my $res = get("http://maps.google.co.jp/maps?q=$lat,$lon");
	if($res =~ /pp-place-title\"><span>([^<]+)<\/span>/){
	    $place=$1;
	}
    }    
    return ($place);

}

sub get_latlon_navitime
{
#http://www.navitime.co.jp/?keyword=%E3%83%92%E3%83%AB%E3%82%BA&ctl=0110

    use utf8;
    my ($self,$addr) = @_;
    my ($lat,$lon);
    $addr = encode("utf8",$addr);
    #print "$addr\n";
 #   $addr =~ s/(\W)/'%'.unpack('H2',$1)/eg;
     my $res = get("http://www.navitime.co.jp/?keyword=$addr&ctl=0110");

    my @lines=split(/[\r\n]/,$res);
    my $startFlag=0;
    my $targetLine;
    for(my $i=0;$i<@lines;$i++){
	if($lines[$i] =~ /店舗\/施設/){
	    $startFlag = 1;
	}
	if($startFlag == 1){
	    if($lines[$i] =~ /class=\"Address\">([^<]+)</){
		$targetLine=$1;
		last;
	    }
	}
    }
#    print $targetLine,"\n";
    ($lat,$lon)=$self->get_latlon_gmap($targetLine);
    
    return ($lat,$lon);
}


return 1;
