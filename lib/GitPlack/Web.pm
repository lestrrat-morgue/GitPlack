package GitPlack::Web;
use Moose;
use Encode qw(encode_utf8);
use Git::PurePerl;
use GitPlack::Web::Context;
use GitPlack::Web::Router;
use Plack::Request;
use Template;
use Template::Stash::ForceUTF8;
use namespace::clean -except => qw(meta);

has router => (
    is => 'ro',
    isa => 'GitPlack::Web::Router',
    lazy_build => 1,
);

has repos => (
    is => 'ro',
    isa => 'HashRef',
    required => 1,
    # { id => \%data }, where
    # %data should contain "name" (the displayed name)
    # and "directory" where the .git files are found.
    # "id" is used as the URL component to identify this repo
);

has template => (
    is => 'ro',
    isa => 'Template',
    lazy_build => 1,
);

sub _build_template {
    return Template->new(
        INCLUDE_PATH => 'root',
        STASH => Template::Stash::ForceUTF8->new(),
    );
}

sub run_template {
    my ($self, $c, $template, $args) = @_;

    my $output;
    $self->template->process($template, $args, \$output) or
        die $self->template->error;
    $c->response->body($output);
}

sub get_repository {
    my ($self, $id) = @_;

    my $repo_spec = $self->repos->{$id};
    return unless $repo_spec;

    my $dir = $repo_spec->{directory};
    return unless $repo_spec;

    return unless -d $dir;

    return Git::PurePerl->new( directory => $dir );
}

sub new_context {
    my ($self, $env) = @_;
    return GitPlack::Web::Context->new(
        app     => $self,
        request => Plack::Request->new($env),
    );
}

sub _build_router {
    return GitPlack::Web::Router->new();
}

sub psgi_handler {
    my $self = shift;
    return sub {
        my $env   = shift;
        my $c     = $self->new_context($env);
        my $res   = $c->dispatch();
        $res->body( encode_utf8( $res->body ) );
        return $res->finalize;
    }
}

__PACKAGE__->meta->make_immutable();

1;
