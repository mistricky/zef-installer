use Terminal::ANSIColor;

sub prompt(Str $msg --> Str) {
	print color('green'), $msg ~ ": ", color('reset');

	return $*IN.get;
}

sub is-address(Str $p --> Bool) {
	return so $p ~~ m/^https?\:\/\//;
}

sub to-bool(Str $str where *.uc eq "N"|"Y" --> Bool) {
	if $str.uc eq "N" {
		return False;
	}

	return True;
}

sub extract-name-by-addr(Str $addr --> Match){
	return ($addr ~~ m/\/(<-[\/]>+)$/)[0];
}

my $zef-install = -> $package-name {
	shell "zef install $package-name"
}

my $address-processor = -> Str $address {
	shell "git clone $address";

	say "==> install $address";

	$zef-install(extract-name-by-addr("./" ~ $address))
}

my $name-processor = -> Str $name, Bool $is-local {
	my Str $prefix = $is-local ?? "./" !! "";
	my Str $parsed-name = $prefix ~ $name;

	$zef-install($parsed-name)
}

my $dispatcher = -> Str $p, Bool $is-local {
	if is-address($p) {
		$address-processor($p);
	} else {
		$name-processor($p, $is-local);
	}
}

sub MAIN(Str :package-addr(:$p), Bool :is-local(:$l) = False){
	loop {
		unless $p.defined && so $p {
			say "Do you forget input address of package or package name?";
			$p := prompt "package name or address of package";

			next;
		}

		last;
	}

	$dispatcher($p, $l)
}
