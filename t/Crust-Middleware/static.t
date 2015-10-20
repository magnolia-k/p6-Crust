use v6;
use Test;
use Crust::Test;
use Crust::Builder;
use Crust::Middleware::Static;
use HTTP::Request;

$Crust::Test::Impl = "MockHTTP";

# TODO: Need to port more tests

my $app = builder {
    enable "Static",
        path => sub {
            # Perl6 strings are immutable, so you can't just modify
            # the path and expect the changes to be visible from the caller
            my $match = @_[0].subst-mutate(rx<^ '/share/'>, "");
            return ($match, @_[0]);
        },
        root => "share";
    -> %env {
        200, [ 'Content-Type' => 'text/plain' ], [ 'Hello World' ];
    };
};

test-psgi
    client => -> $cb {
        my $req = HTTP::Request.new(GET => "http://localhost/share/face.jpg");
        my $res = $cb($req);
        is $res.code, 200;
    },
    app => $app;

done-testing;