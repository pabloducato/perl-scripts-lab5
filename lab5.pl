use strict;
use warnings FATAL => 'all';
use autodie qw(:all);
# use Net::LDAP;

my $var = 0;
my $filename = './zamowienia.eml';
my $orderName;
open(my $fh, '<:encoding(UTF-8)', $filename)
    or die "Could not open file '$filename' $!";
my $str;
my $global_num = "";
my $senderMail;
my $mail;
my $substring;

my $NIPODBIORCY = 9290097448;
my $DATADOSTAWY = "2009-09-15";
my $PLATNIK = "WANDA CZAJKA";
my $NAZWAODBIORCY = "WANDA CZAJKA ZIEL-GORA MIESZKA I 1";

sub retrieve_email {

    open(my $fh, '<:encoding(UTF-8)', $filename)
    or die "Could not open file '$filename' $!";

        while (my $row = <$fh>) {
        chomp $row;

            if ($row =~ m/From:/) {
                $senderMail = $row;
                my $index = index($senderMail, ' ');
                $mail = substr($senderMail, $index+1, length $senderMail);
            }

        }
    return $mail;
}

sub decode_email {

    open(my $fh, '<:encoding(UTF-8)', $filename)
    or die "Could not open file '$filename' $!";

        while (my $row = <$fh>) {
        chomp $row;

            if ($row =~ m/From:/) {
                $senderMail = $row;
                my $index = index($senderMail, ' ');
                $mail = substr($senderMail, $index+1, length $senderMail);
            }

            if ($row =~ m/ZAMOWIENIA HERBAPOL/) {
                $var = $var + 1;
                $orderName = './HERBAPOL_'.$var.'.csv';
            } elsif ($row =~ m/NIP/) {
                ($NIPODBIORCY) = $row =~ /(\d+)/;
            } elsif ($row =~ m/DATA DOSTAWY/) {
                ($DATADOSTAWY) = $row =~ /([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))/;
            } elsif ($row =~ m/PLATNIK/) {
                $PLATNIK = $row;
                my $index = index($PLATNIK, '|');
                $substring = substr($PLATNIK, $index+22, length $PLATNIK);
                $substring =~ tr/ //ds;
                $substring = substr($substring, 0, (length $substring)-1);
                $PLATNIK = $substring;
            } elsif ($row =~ m/ODBIORCA/) {
                $NAZWAODBIORCY = $row;
                my $index = index($NAZWAODBIORCY, '|');
                $substring = substr($NAZWAODBIORCY, $index+22, length $NAZWAODBIORCY);
                $substring =~ s/\s*$//;
                $substring = substr($substring, 0, (length $substring)-14);
                $NAZWAODBIORCY = $substring;
            } elsif ($row =~ m/================================================================================/) {
                chomp $row;
            } elsif ($row =~ m/NR ZAMOWIENIE/) {
                chomp $row;
            } elsif ($row =~ m/HURTOWNIA/) {
                chomp $row;
            } elsif ($row =~ m/DATA ZAMOWIENIA/) {
                chomp $row;
            } elsif ($row =~ m/PRACOWNIK/) {
                chomp $row;
            } elsif ($row =~ m/FORMA PLATNOSCI/) {
                chomp $row;
            } elsif ($row =~ m/--------------------------------------------------------------------------------/) {
                chomp $row;
            } elsif ($row =~ m/UWAGI/) {
                open my $fh, '>>', $orderName or die $!;
                print {$fh} $NIPODBIORCY . ";";
                print {$fh} $DATADOSTAWY . ";";
                print {$fh} $PLATNIK . ";";
                print {$fh} $NAZWAODBIORCY . "\n";
            } elsif ($row =~ m/Koniec zamowienia/ && $var != 12) {
                $str = $row;
                $str =~ s/[^0-9]//g;
                my $localOrderName = './HERBAPOL_'.$str.'.csv';
                rename "$orderName", "$localOrderName" or die "Cannot rename file: $!";
                $var = $var + 1;
            } elsif ($row =~ m/Koniec zamowienia 3827462/) {
                $str = $row;
                $str =~ s/[^0-9]//g;
                my $localOrderName = './HERBAPOL_'.$str.'.csv';
                rename "$orderName", "$localOrderName" or die "Cannot rename file: $!";
                chomp $row;
            } else {
                if ($var == 0 || $var == 13) {
                chomp $row;
                } elsif ($row =~ m/------=_Part_10749_400571625.1252936448654--/) {
                chomp $row;
                } else {
                    open my $fh, '>>', $orderName or die $!;
                    print {$fh} $row . "\n";
                }
            }
        }

        close $fh;
        unlink './HERBAPOL_1.csv';
        print "$mail\n";
        print "done\n";

}

# sub ldap_auth_test {

#         my $ldap_server='127.0.0.1';
#         my $ldap_port = 389;
#         my $base = 'dc=osdp,dc=pl,mail='.$mail;
#         my $scope = 'sub';

#         my ($msg_ok, $msg_unacceptable, $msg_misused,$msg_tempfailure,
#             $msg_badldap,$msg_ldapgeneral) =
#         ("LDAP_AUTH_INFO: Uwierzytelnianie OK\n",
#             "LDAP_AUTH_INFO: Uwierzytelnianie niepoporawne\n",
#             "LDAP_AUTH_INFO: Otrzymano złą liczbę parametrów.\n",
#             "LDAP_AUTH_ERROR: Coś nie tak. Sprawdź połączenie z serwerem LDAP.\n",
#             "LDAP_LDAP_ERROR: Nie mogę poprawnie połączyć się z LDAP.\n",
#             "LDAP_LDAP_ERROR: Błąd=");

#         print ldap_auth('stud','nowehaslo');
#         print ldap_auth('stud2','pei');

#         sub ldap_auth {
#             my ($username, $password) = @_;
#             my $dn = &ldap_search($username);
#             if ($dn ne '') {
#             print "Znalazłem: ".$dn."\n";
#                 $ldap = Net::LDAP->new($ldap_server) or &mydie();
#                 $mesg = $ldap->bind($dn, password => $password );
#                 $ldap->unbind;   # już się rozłączę a komunikat o poprawniści|niepoprawności mam w zmiennej $mesg
#                 if ( $mesg->code ) {
#                     return $msg_unacceptable;
#                 } else {
#                     return $msg_ok;
#                 }
#             } else {
#                 return $msg_unacceptable;
#             }
#         }

#         sub ldap_search {
#             ($username) = @_;
#             $ldap = Net::LDAP->new(
#                                 $ldap_server,
#                                 port => $ldap_port
#                                 ) or &mydie();
#             $mesg = $ldap->bind ; 
#             if ( $mesg->code ) {
#                 &mydie($mesg->code);
#             }
#             $mesg = $ldap->search (
#                                 base   => $base,
#                                 scope  => $scope,
#                                 filter => "(cn=$username)"
#                                 );
#             $mesg->code && &mydie($mesg->error);
#             my $numfound = $mesg->count ;
#             my $dn="" ;
#             if ($numfound) {
#                 my $entry = $mesg->entry(0);
#                 $dn = $entry->dn ;
#             }
#             $ldap->unbind;  
#             return $dn ;
#         }

#         sub mydie {
#             if (scalar(@_) > 0) {
#                 $fherr->print($msg_ldapgeneral . $_[0] . "\n");
#             } else {
#                 $fherr->print($msg_badldap);
#             }
#             exit $resp_tempfailure;
#         }

# }

my $retrievedMail = retrieve_email();
if ($retrievedMail ne "") {
    my $answer = "OK";
    # my $answer = ldap_auth_test();
    if ($answer eq "OK") {
        decode_email();
    } else {
        print "Żądany e-mail nadawcy nie występuje w uslugach katalogowych"
    }
} else {
    print "Żądany plik e-mail nie zawiera poprawnego adresu mailowego"
}

# my $retrievedMail = retrieve_email();
# if ($retrievedMail ne "") {
#     my $answer = ldap_auth_test();
#     if ($answer eq "OK") {
#         decode_email();
#     } else {
#         print "Żądany e-mail nadawcy nie występuje w uslugach katalogowych"
#     }
# } else {
#     print "Żądany plik e-mail nie zawiera poprawnego adresu mailowego"
# }

