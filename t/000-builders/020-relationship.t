#!perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

BEGIN {
    use_ok('PONAPI::Relationship::Builder');
    use_ok('PONAPI::Links::Builder');
}

=pod

TODO:

=cut

subtest '... testing constructor' => sub {

    my $b = PONAPI::Relationship::Builder->new;
    isa_ok($b, 'PONAPI::Relationship::Builder');

    can_ok( $b, $_ ) foreach qw[
        add_links
        has_links

        add_meta
        has_meta

        add_data
        has_data

        build
    ];

};

subtest '... testing constructor errors' => sub {

    is(
        exception { PONAPI::Relationship::Builder->new },
        undef,
        '... got the (lack of) error we expected'
    );

};

subtest '... testing links sub-building' => sub {
    my $b = PONAPI::Relationship::Builder->new;

	ok(!$b->has_links, "new relationship should not have links");

    $b->add_links({
        related => "/related/2",
        self    => "/self/1",
    });
    
    ok($b->has_links(), "relationship should now have links");

    is_deeply(
        $b->build,
        {
            links => {
                self    => "/self/1",
                related => "/related/2",
            }
        },
        '... Relationship with links',
    );
};

	
subtest '... testing relationship with meta' => sub {
    my $b = PONAPI::Relationship::Builder->new;
    
    ok(!$b->has_meta, "new relationship shouldn't have meta");
    
    is(
        exception { $b->add_meta(info => "a meta info") },
        undef,
        '... got the (lack of) error we expected'
   	);
   	
   	ok($b->has_meta, "relationship should have meta");

    is_deeply(
        $b->build,
        {
            meta => { info => "a meta info", }
        },
        '... Relationship with meta',
    );
};

subtest '... testing relationship with multiple meta' => sub {
    my $b = PONAPI::Relationship::Builder->new;
    
    ok(!$b->has_meta, "new relationship shouldn't have meta");
    
    is(
        exception { $b->add_meta(info => "a meta info") },
        undef,
        '... got the (lack of) error we expected'
   	);
   	
   	ok($b->has_meta, "relationship should have meta");
   	
   	is(
        exception { $b->add_meta(physic => "a meta physic") },
        undef,
        '... got the (lack of) error we expected'
   	);

    is_deeply(
        $b->build,
        {
            meta => { 
            	info => "a meta info", 
            	physic => "a meta physic",
            }
        },
        '... Relationship with meta',
    );
};

subtest '... testing relationship with meta object' => sub {
    my $b = PONAPI::Relationship::Builder->new;
    
    ok(!$b->has_meta, "new relationship shouldn't have meta");
    
    is(
        exception { $b->add_meta(        	
            foo => {
	        	info => "a foo info",
	        }
        )},
        undef,
        '... got the (lack of) error we expected'
   	);
   	
   	ok($b->has_meta, "relationship should have meta");

    is_deeply(
        $b->build,
        {   
        	meta => {
	            foo => {
		        	info => "a foo info",
		        }
        	}
        },
        '... Relationship with meta object',
    );
};

subtest '... testing relationship with multiple data' => sub {
    my $b = PONAPI::Relationship::Builder->new;
    
    $b->add_data({
        id => "1",
        type => "articles",
    });
    
    $b->add_data({
        id => "1",
        type => "nouns"
    });

    is_deeply(
        $b->build,
        {
            data =>
            [
                {
                    id => "1",
                    type => "articles",
                },
                {
                    id => "1",
                    type => "nouns"
                }
            ]
        },
        '... Relationship with multiple data',
    );
};

subtest '... testing relationship with one data object' => sub {
    my $b = PONAPI::Relationship::Builder->new;
    
    $b->add_data({
          id => "1",
        type => "articles",
    });

    is_deeply(
        $b->build,
        {
            data => {
                id => "1",
                type => "articles",
            }
        },
        '... Relationship with one data',
    );
};

subtest '... testing build errors' => sub {

    subtest '... for empty Relationship' => sub {
        my $b = PONAPI::Relationship::Builder->new;
        is_deeply(
            $b->build,
            {
                errors => [{
                    detail => 'Relationship should contain at least one of "links", "data" or "meta"',
                }],
            },
            '... No empty Relationship',
        );
    };

    subtest '... links' => sub {
        my $b = PONAPI::Relationship::Builder->new;
        
        like(
            exception { $b->add_links({
                about => "/about/something",
            })},
            qr/invalid key: about/,
            '...about is an invalid key for the links object'
        );
    };
};

done_testing;
