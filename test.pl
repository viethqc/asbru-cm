#!/usr/bin/perl

# This will print "Hello, World"

use XML::LibXML;
use File::Copy qw(move);

$array = '  -x -C -o "ProxyCommand=nc -x 127.0.0.1:1111 %h %p" -R  localhost:1345:192.168.5.8:3128  localhost:3128:192.168.5.8:3128 ';
$array = '-o "ProxyCommand=nc -x 127.0.0.1:1080 %h %p"';

# for $i (0..length($array)-1){
#     $char = substr($array, $i, 3);
#     if ($char == "-o ") {
#         print "Index: $i, Text: $char \n";   
#     }
# }

sub get_ssh_options {
    $str = @_[0];

    $iOptions = index($str, "-o ");
    if ($iOptions == -1) {
        return ""
    }

    $firstQuote = index($str, "\"", $iOptions);
    if ($firstQuote == -1) {
        return ""
    }

    $lastQuote = index($str, "\"", $firstQuote + 1);
    if ($lastQuote == -1) {
        return ""
    }

    $sOptions = substr($str, $iOptions, $lastQuote - $iOptions  + 1);

    return $sOptions
}

$output = get_ssh_options($array);
print "$output\n";

sub get_filezilla_config {
    $login = getlogin || getpwuid($<);
    $filezilla_conf = "/home/" . $login ."/.config/filezilla/filezilla.xml";

    return $filezilla_conf
}

sub edit_filezilla_config {
    my $proxy_host = shift;
    my $proxy_port = shift;

    my $filezilla_conf = get_filezilla_config();
    my $filezilla_conf_bak = $filezilla_conf . ".bak";
    move $filezilla_conf, $filezilla_conf_bak;

    my $dom = XML::LibXML->load_xml(location => $filezilla_conf_bak);

    my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy type"]/text()');
    if ($proxy_host != "" && $proxy_port != "") {
        $node->setData(2);
    } else {
        $node->setData(0);
    }


    my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy host"]/text()');
    $node->setData($proxy_host);

    my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy port"]/text()');
    $node->setData($proxy_port);

    $dom->toFile($filezilla_conf);

    return ($filezilla_conf, $filezilla_conf_bak);
}

sub open_file_zilla {
    my $host = shift;
    my $port = shift;
    my $user = shift;
    my $pass = shift;
    my $proxy_host = shift;
    my $proxy_port = shift;

    ($filezilla_conf, $filezilla_conf_bak) = edit_filezilla_config($proxy_host, $proxy_port);
    
    my $command = sprintf("filezilla %s:%s@%s:%s", $user, $pass, $host, $port);
    print "$command\n";

    unless (fork) {
        system($command);
        exit;
    }

    sleep(5);
    unlink $filezilla_conf;
    move $filezilla_conf_bak, $filezilla_conf;
}

# get_filezilla_config();
#edit_filezilla_config("127.0.0.1", 3214);
# system("filezilla");

open_file_zilla("10.0.2.16", 22, "test", "a", "127.0.0.1", 1080);

sub get_proxy_info_from_ssh_options {
    my $ssh_option = shift;

    $ip_port = "";
    my @arr_ssh_options = split(" ", $ssh_option); 

    foreach my $i (@arr_ssh_options)  
    {
        if ($i =~ "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]):[0-9]+\$"){
            $ip_port = $i;
            last;
        }
    }

    my @arr_ip_port = split(":", $ip_port);
    my $ip = @arr_ip_port[0];
    my $port = @arr_ip_port[1];

    print "$ip $port\n";
}

get_proxy_info_from_ssh_options($array)



# my $xml_file = 'filezilla.xml';

# my $dom = XML::LibXML->load_xml(location => $xml_file);

# my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy type"]/text()');
# $node->setData(4);
# print $node->to_literal() . "\n";

# my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy host"]');
# print $node->to_literal() . "\n";

# my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy port"]');
# print $node->to_literal() . "\n";

# $dom->toFile("a.xml");