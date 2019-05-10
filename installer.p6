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
	$zef-install()
}

my $dispatcher = -> Str $p, Bool $is-local {
	if is-address($p) {
		$address-processor($p);
	} else {
		$name-processor($p, $is-local);
	}
}

sub MAIN(Str :package-addr(:$p)){
	my Str $is-local = "N";

	loop {
		unless $p.defined && so $p {
			say "Do you forget input address of package or package name?";
			$p := prompt "package name or address of package";

			last if is-address($p);

			next;
		}

		$is-local := prompt "Install $p in local? (Y/N)";

		unless $is-local.uc eq "N"|"Y" {
				say "Please choose N or Y";

				next;
		}

		last;
	}

	$dispatcher($p, to-bool $is-local)
}
