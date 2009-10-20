use lib "lib";
use strict;
use Plack::Builder;
use GitPlack::Web;
use YAML ();

# XXX Bad hardcoding - But I'm getting bored.
$ENV{GITPLACK_CONFIG} ||= 'gitplack.yaml';
my $config = YAML::LoadFile( $ENV{GITPLACK_CONFIG} );
my $app = GitPlack::Web->new(
    repos => $config->{repos},
);
builder {
    # middlewere goes here
    enable "Plack::Middleware::Static",
        path => qr{^(/static|favicon\.ico)},
        root => 'root/'
    ;

    $app->psgi_handler();
}