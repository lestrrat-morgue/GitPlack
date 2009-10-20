package GitPlack::Web::Context;
use Moose;
use Plack::Request;
use namespace::clean -except => qw(meta);

has app => (
    is => 'ro',
    isa => 'GitPlack::Web',
    required => 1,
);

has request => (
    is => 'ro',
    isa => 'Plack::Request',
    required => 1,
);

has response => (
    is => 'ro',
    isa => 'Plack::Response',
    lazy_build => 1,
);

sub _build_response {
    my $self = shift;
    return $self->request->new_response(200, [ 'Content-Type' => 'text/html; charset=utf-8' ]);
}

sub dispatch {
    my $self = shift;

    my ($controller, $args) =
        $self->app->router->match( $self->request );
    if (! $controller) {
        $self->response->code(404);
        $self->response->body("Resource Not Found");
    } else {
        $controller->run( $self, $args );
    }

    return $self->response;
}

sub run_template {
    my $self = shift;
    $self->app->run_template($self, @_);
}

__PACKAGE__->meta->make_immutable();

1;
