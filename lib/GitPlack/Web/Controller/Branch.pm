package GitPlack::Web::Controller::Branch;
use Moose;
use namespace::clean -except => qw(meta);

sub run {
    my ($self, $c, $args) = @_;

    my $repo = $c->app->get_repository( $args->{repo_id} );
    if (! $repo) {
        die "404";
    }

    my $branch = $repo->ref("refs/heads/$args->{branch_id}");
    if (! $repo) {
        die "404";
    }
    
    $args->{branch} = $branch;
    $c->run_template('tree/commits.tt', $args);
}

__PACKAGE__->meta->make_immutable();

1;
