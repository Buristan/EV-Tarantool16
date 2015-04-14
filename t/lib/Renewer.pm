package Renewer;

use 5.010;
use strict;
use Test::More;
use Test::Deep;
use FindBin;
use lib "t/lib","lib","$FindBin::Bin/../blib/lib","$FindBin::Bin/../blib/arch";
use EV;
use EV::Tarantool;
use Time::HiRes 'sleep','time';
use Data::Dumper;
use Errno;
use Scalar::Util 'weaken';
# use AE;


my @data = (
	["t1", "t2", 17, -745, "heyo"],
	["t1", "t2", 2, [1, 2, 3, "str1", 4]],
	["t1", "t2", 3, {key1 => 'value1', key2 => 42, 33 => Types::Serialiser::true, 35 => Types::Serialiser::false}],
	["tt1", "tt2", 456, 5]
);

sub insertion {
	my ($c, $space, $args, $current, $cb) = @_;

	if ($current >= scalar(@$args)) {
	# if ($current >= 1) {
		$cb->();
		return;
	}

	$c->eval("return box.space.$space:insert{...}", $$args[$current], sub {
		my $a = @_[0];
		# say Dumper \@_;
		insertion($c, $space, $args, $current + 1, $cb);
	});
}

sub deletion {
	my ($c, $space, $args, $current, $cb) = @_;

	if ($current >= scalar(@$args)) {
		$cb->();
		return;
	}

	$c->delete($space, [@{@$args[$current]}[0..2]], sub {
		my $a = @_[0];
		# say Dumper \@_;
		deletion($c, $space, $args, $current + 1, $cb);
	});
}

sub renew_tnt {
	my ($c, $space, $cb) = @_;
	$c->select($space, [], { hash => 0 }, sub {
		my $a = @_[0];

		deletion $c, $space, $a->{tuples}, 0, sub {
			insertion($c, $space, \@data, 0, $cb);
		};

	});
}

# renew_tnt(sub {
# 	EV::unloop;
# });
# EV::loop;
