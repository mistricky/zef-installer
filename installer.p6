use Terminal::ANSIColor;

sub prompt(Str $msg --> Str) {
	print color('green'), $msg ~ ": ", color('reset');

	return get;
}

sub isAddress(Str $p --> Bool){
	return so $p ~~ m/^https?\:\/\//;
}

sub MAIN(Str :package-addr(:$p)){
	# my $package-payload = $p;
	my Str $is-local;

	loop {
		unless $p.defined && so $p {
			say "Do you forget input address of package or package name?";
			$p := prompt "package name or address of package";

			next;
		}

		$is-local = prompt "Install $p in local? (Y/N)";

		unless $is-local.uc eq 'N'|'Y' {
				say "Please choose N or Y";

				next;
		}

		last;
	}

	say isAddress($p);
}
