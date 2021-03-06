use strict;
use warnings;

use Test::More;
use Test::Quattor::ProfileCache;
use Test::Quattor::TextRender::Component;
use Cwd qw(getcwd);

=pod

=head1 DESCRIPTION

Test the component unittest. This is NOT an example to use
the Test::Quattor::TextRender::Component test().

=cut

# mimic pom.xml test structure under target
# -> create pan dir with components/mycomp/
# -> copy TT files to share/templates/quattor/mycomp
use File::Copy::Recursive qw(rcopy);
my $basepath = getcwd()."/src/test/resources/components/ncm-mycomp";
my $target = getcwd()."/target";
# whole pan dir
rcopy("$basepath/pan",  "$target/pan") or
    die "copy $basepath/pan to $target: $!";
# TT files
rcopy("$basepath/resources/main.tt",  "$target/share/templates/quattor/mycomp/") or
    die "copy $basepath/resources/main.tt to $target/share/templates/quattor/mycomp: $!";
rcopy("$basepath/resources/extra.tt",  "$target/share/templates/quattor/mycomp/") or
    die "copy $basepath/resources/extra.tt to $target/share/templates/quattor/mycomp: $!";


my $st = Test::Quattor::TextRender::Component->new(
    component => "mycomp",
    # exception here to set the basepath. Default should be ok for actual usage
    basepath => "$basepath/resources",
    );

isa_ok($st, "Test::Quattor::TextRender::Component",
       "Returns Test::Quattor::TextRender::Component instance for service");
# the actual method to test
$st->test();

my $dirs = get_profile_cache_dirs();
like($dirs->{cache},
     qr{/target/test/cache/components/mycomp$},
     "cache root set to pannamespace");

# Test the skippan on a directory that has no pan files
# tests would fail if skippan isn't set to true
$basepath = getcwd()."/src/test/resources/notacomponent";
rcopy("$basepath/resources/main.tt",  "$target/share/templates/quattor/notacomponent/") or
    die "copy $basepath/resources/main.tt to $target/share/templates/quattor/notacomponent: $!";
$st = Test::Quattor::TextRender::Component->new(
    component => "notacomponent",
    skippan => 1,
    # exception here to set the basepath. Default should be ok for actual usage
    basepath => "$basepath/resources",
    );
isa_ok($st, "Test::Quattor::TextRender::Component",
       "Returns Test::Quattor::TextRender::Component instance for service");
# the actual method to test
$st->test();


done_testing();
