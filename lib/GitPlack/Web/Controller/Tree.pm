package GitPlack::Web::Controller::Tree;
use Moose;
use namespace::clean -except => qw(meta);

sub run {
    my ($self, $c, $args) = @_;

    my $repo = $c->app->get_repository( $args->{repo_id} );
    if (! $repo) {
        die "404";
    }

    my $branch = $repo->ref("refs/heads/$args->{branch_id}");
    if (! $branch) {
        die "404";
    }
    $args->{branch} = $branch;

    my $path = $args->{path};
    my @comps = split(/\//, $path);

    if (! @comps) {
        # We're at root. the target object is the branch
        $args->{path_comps} = [];
        $args->{object_map} = {},
        $args->{object}     = $branch->tree;
        $args->{template} = 'tree/view.tt';
    } else {
        my $parent = $branch->tree;
        my @left = @comps;
        my %comps;
        while (my $next = shift @left) {
            my $found = 0;
            foreach my $e ($parent->directory_entries) {
                if ($e->filename eq $next) {
                    $found = $e;
                    last;
                }
            }
            if (! $found) {
                die "404";
            }

            $parent = $found->object;
            $comps{ $next } = $parent;

            if ($parent->kind ne 'tree' && scalar @left > 0) {
                die "404";
            }
        }

        my $last = $comps{ $comps[-1] };
        $args->{path_comps} = \@comps;
        $args->{object_map} = \%comps;
        $args->{object}     = $last;

        $args->{template} = ($last->kind eq 'tree') ? 'tree/view.tt' : 'blob/view.tt';
    }

    $c->run_template($args->{template}, $args);
}

__PACKAGE__->meta->make_immutable();

1;
