package HTML::FormFu::Constraint::_others;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(qw/
    others 
    attach_errors_to_base
    attach_errors_to_others
    attach_errors_to /);

sub mk_errors {
    my ( $self, $failed, $names_failed, $names_attach ) = @_;
    
    my $force = $self->force_errors || $self->parent->force_errors;
    my @attach;
    
    if ( $self->attach_errors_to ) {
        push @attach, @{ $self->attach_errors_to }
            if $failed || $force;
    }
    elsif ( $self->attach_errors_to_base || $self->attach_errors_to_others ) {
        push @attach, $self->name
            if $self->attach_errors_to_base
               && ( $failed || $force );
        
        push @attach, ref $self->others ? @{ $self->others } : $self->others
            if $self->attach_errors_to_others
               && ( $failed || $force ); 
    }
    elsif ( $force ) {
        push @attach, @$names_attach;
    }
    elsif ( @$names_failed ) {
        push @attach, @$names_failed
            if $failed;
    }
    
    my @errors;
    
    for my $name (@attach) {
        my $field = $self->form->get_field({ name => $name })
            or die "others() field not found: '$name'";
        
        my $error = $self->mk_error;
        
        $error->parent($field);
        
        $error->forced(1)
            if ( !$failed && $force && grep { $name eq $_ } @$names_attach )
            || ! grep { $name eq $_ } @$names_failed;
        
        push @errors, $error;
    }
    
    return @errors;
}

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
    $clone->others( dclone $self->others )
        if ref $self->others;
    
    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::_other - Base class for constraints needing others() method

=head1 METHODS

=head2 others

Arguments: \@field_names

=head2 attach_errors_to_base

If true, any error will cause the error message to be associated with the 
field the constraint is attached to.

Can be use in conjunction with L</attach_errors_to_others>.

Is ignored if L</attach_errors_to> is set.

=head2 attach_errors_to_others

If true, any error will cause the error message to be associated with every 
field named in L</others>.

Can be use in conjunction with L</attach_errors_to_base>.

Is ignored if L</attach_errors_to> is set.

=head2 attach_errors_to

Arguments: \@field_names

Any error will cause the error message to be associated with every field 
named in L</attach_errors_to>.

Overrides L</attach_errors_to_base> and L</attach_errors_to_others>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.