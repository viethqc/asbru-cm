#!/usr/bin/perl

# This will print "Hello, World"

use XML::LibXML;

$array = '  -x -C -o "ProxyCommand=nc -x 127.0.0.1:1111 %h %p" -R  localhost:1345:192.168.5.8:3128  localhost:3128:192.168.5.8:3128 ';
$array = '-o "ProxyCommand=nc -x 127.0.0.1:1111 %h %p"';

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

my $xml_file = 'filezilla.xml';

my $dom = XML::LibXML->load_xml(location => $xml_file);

my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy type"]/text()');
$node->setData(4);
print $node->to_literal() . "\n";

my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy host"]');
print $node->to_literal() . "\n";

my($node)  = $dom->findnodes('/FileZilla3/Settings/Setting[@name="Proxy port"]');
print $node->to_literal() . "\n";

$dom->toFile("a.xml");