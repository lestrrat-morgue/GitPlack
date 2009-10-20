package GitPlack::Web::Router;
use Moose;
use GitPlack::Web::Controller::Callback;
use GitPlack::Web::Controller::Commit;
use GitPlack::Web::Controller::Branch;
use GitPlack::Web::Controller::Tree;
use namespace::clean -except => qw(meta);

has routes => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy_build => 1
);

sub _build_routes {
    return [
        [
            qr{^/$},
            GitPlack::Web::Controller::Callback->new(
                callback => sub {
                    my ($self, $c) = @_;
                    $c->run_template('index.tt', {
                        repos => $c->app->repos,
                    });
                }
            ),
        ],
        [
            qr{^\/repo/([^/]+)/?$},
            GitPlack::Web::Controller::Callback->new(
                callback => sub {
                    my ($self, $c, $args) = @_;
                    $c->response->redirect("/repo/$args->{repo_id}/branch/master");
                }
            ),
            sub { 
                { repo_id => $1 }
            }
        ],
        [
            qr{^\/repo/([^/]+)/branch/([^/]+)/commits$},
            GitPlack::Web::Controller::Branch->new(),
            sub { 
                { repo_id => $1, branch_id => $2 }
            }
        ],
        [
            qr{^\/repo/([^/]+)/branch/([^/]+)/commit/([a-z0-9]+)$},
            GitPlack::Web::Controller::Commit->new(),
            sub { 
                { repo_id => $1, branch_id => $2, commit_id => $3 }
            }
        ],
        [
            qr{^\/repo/([^/]+)(?:/branch/([^/]+)(?:/(.*))?)?},
            GitPlack::Web::Controller::Tree->new(),
            sub { 
                { repo_id => $1, branch_id => $2, path => $3 }
            }
        ]
    ]
}

sub match {
    my ($self, $req) = @_;

    my $path = $req->uri->path;
    foreach my $route (@{ $self->routes }) {
        if ($path =~ /$route->[0]/) {
            return ( $route->[1], $route->[2] ? $route->[2]->() : {} );
        }
    }
}

__PACKAGE__->meta->make_immutable();

1;
