use inc::Module::Install;

name 'GitPlack';

requires 'namespace::clean';
requires 'Encode';
requires 'Git::PurePerl';
requires 'Moose';
requires 'Plack';
requires 'Plack::Middleware::Static';
requires 'Plack::Request';
requires 'Template';
requires 'Template::Stash::UTF8';

print 
    "After the dependencies are installed, type\n\n",
    "   plackup --app config/gitplack.psgi\n\n",
    "to start the server!\n",
;