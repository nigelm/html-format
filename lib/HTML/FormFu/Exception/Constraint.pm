package HTML::FormFu::Exception::Constraint;

use base 'HTML::FormFu::Exception';

use HTML::FormFu::Util qw( literal );

__PACKAGE__->mk_accessors(qw/ constraint /);

sub name {
    my $self = shift;
    
    return $self->parent->name;
}

sub type {
    my $self = shift;
    
    return $self->constraint->constraint_type;
}

sub class {
    my $self = shift;
    
    if (@_) {
        return $self->{class} = shift;
    }
    
    return $self->{class} if defined $self->{class};
    
    my %string = (
        f => defined $self->form->id     ? $self->form->id     : '',
        n => defined $self->parent->name ? $self->parent->name : '',
        t => defined $self->constraint->constraint_type 
            ? lc( $self->constraint->constraint_type ) : '',
    );
    
    my $class = $self->parent->auto_error_class;
    
    $class =~ s/%([fnt])/$string{$1}/ge;
    
    return $self->{class} = $class;
}

sub message {
    my $self = shift;
    
    if (@_) {
        return $self->{message} = shift;
    }
    
    return $self->{message}           if defined $self->{message};
    return $self->constraint->message if defined $self->constraint->message;
    
    my %string = (
        f => defined $self->form->id     ? $self->form->id     : '',
        n => defined $self->parent->name ? $self->parent->name : '',
        t => defined $self->constraint->constraint_type 
            ? lc( $self->constraint->constraint_type )  : '',
    );
    
    my $message = $self->parent->auto_error_message;
    
    $message =~ s/%([fnt])/$string{$1}/ge;;
    
    return $self->{message} = $self->form->localize( $message );
}

1;