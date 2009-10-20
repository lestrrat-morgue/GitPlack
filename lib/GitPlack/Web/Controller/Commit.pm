package GitPlack::Web::Controller::Commit;
use Moose;
use namespace::clean -except => qw(meta);

sub run {
    my ($self, $c, $args) = @_;

    $c->response->body( "TODO" );
}

__PACKAGE__->meta->make_immutable();

1;
