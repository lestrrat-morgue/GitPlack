package GitPlack::Web::Controller::Callback;
use Moose;
use namespace::clean -except => qw(meta);

has callback => (
    is => 'ro',
    isa => 'CodeRef',
    required => 1
);

sub run {
    my ($self) = @_;
    $self->callback->(@_);
}

__PACKAGE__->meta->make_immutable();

1;
