package LWP::UserAgent::RandomProxyConnect;
use base( "LWP::UserAgent" );

use 5.006;
use strict;
use warnings;
our $AUTOLOAD;
use Carp;

=head1 NAME

LWP::UserAgent::RandomProxyConnect - A LWP::UserAgent extension for becoming an omnipresent client.

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';


=head1 SYNOPSIS

This Object does exactly the same than the L<LWP::UserAgent> class with the a
new feature: it can make each HTTP request throw a different proxy each time.
Also, a few methods improve the proxy list management, and makes the iterative
connections faster.

=head1 CONSTRUCTOR

When this class is invoked as:

    my $obj = LWP::UserAgent::RandomProxyConnect->new
    
several test will be made. First, the class must find a valid file with a proxy
list, if not, this object will stop. This file must be placed in the environmental
variable $ENV{PROXY_LIST}.

However, the class can be invoked as:

    my $obj = LWP::UserAgent::RandomProxyConnect->new(-proxy_list => $proxy_file_path)
    
the created object will search the file at the specified path.

Furthermore, whatever the method you use to invoke the class, the object will
stop if the specified file doest not exists, is not readable or there is no proxy
found into it.

=cut

sub new{
    
    my ($class, %arg) = @_;
    my $self = bless {}, $class;
    
    # The following block is not really needed, but it is
    # paste here for teaching reasons.
    # The shorter way to set the unique attribute that the class
    # need is like so:
    #
    # if($arg{-proxy-list}){
    #   $self->set_proxy_list($arg{-proxy-list});      
    # }
    #
    
    # See below to see all attributes
    foreach my $attribute ($self->_all_attributes()){
        # E.g. attribute = "_name", argument = "name"
        my ($argument) = ($attribute =~ /^_(.*)/);
        # If explicitly given
        if(exists $arg{$argument}){
            $self->{$attribute} = $arg{$argument};
        }
        # Set to default
        else{
            $self->{$attribute} = $self->_attribute_default($attribute);            
        }
    }
    
    # Let's load a new "current_proxy". By this way, if there are any errors
    # the object will stop.
    $self->_renove_proxy;
    
    return $self;
    
}

=head1 THE EXTENDED METHOD

=head2 request

This method is exactly the same than LWP::UserAgent->request L<LWP::UserAgent>
with the implemented proxy-change in each request. It obiously make the connection
slowler. NOTICE: Only http and https protocols are allowed.

=cut

sub request
{
    
    my($self, $request, $arg, $size, $previous) = @_;
    
    # Get a new proxy from the list
    $self->_renove_proxy;

    # Get the proxy
    my $new_proxy = $self->get_current_proxy;
    my $allowed_protocols = $self->get_allowed_protocols;
    # Set the proxy in the user agent
    $self->proxy($allowed_protocols,$new_proxy);
    
    # Set the "last proxy used" value
    $self->set_last_proxy($new_proxy);
    
    # Make the request
    my $response = $self->SUPER->request($request,$arg,$size,$previous);
    
    # Return exactly the same than LWP::UserAgeng->request($request) method
    return ($response);
    
}


=head1 ATTRIBUTES

=head2 proxy_list

The C<proxy_list> attribute contains the string with the proxy list file path.
The accessor method:

    my $proxy_list = $obj->get_proxy_list;
    
returns such string.

Also it can be set by the mutator method:

    $obj->set_proxy_list($new_proxy_list_value);

=head2 allowed_protocols

=cut
{
    # A list of all attributes wiht default values and read/write/required properties
    my %_attribute_properties = (
        _proxy_list        => [$ENV{"PROXY_LIST"}, "read.write"], # The path to the proxy list file
        _allowed_protocols => [['http','https'], "read.write"],
        _current_proxy     => ["????:??", "read.write"],
        _last_proxy        => ["????:??", "read.write"]
    );
    
    # The list of all attributes
    sub _all_attributes {
        keys %_attribute_properties;
    }
    
    # Return the default value for a given attribute
    sub _attribute_default{
        my ($self,$attribute) = @_;
        $_attribute_properties{$attribute}[0];
    }
    
}




=head1 METHODS FOR HANDLING THE PROXY LIST

=head2 _renove_proxy

This function returns a new random proxy from the list. This return value
is a string with the format: <proxyUrlorIP>:<port>. This is just a query
for a single request.

=cut

sub _renove_proxy {
    
    my ($self) = @_;
    
    if(1){
        my $obj_name = ref($self);
        #croak("The object ".$obj_name." could not load any proxy at ".$self->get_proxy_list."\n");
    }
    
    return 0;
    
}






#
# The AUTOLOAD method to get/set the class attributes
# sub get_attribute {...}
# sub set_attribute {...}
sub AUTOLOAD{
    
    my ($self,$newvalue) = @_;
    
    my ($operation,$attribute) = ($AUTOLOAD =~ /(get|set)(_\w+)$/);
    
    # Is this a legal method name?
    unless($operation && $attribute){ croak "Method name $AUTOLOAD is not the recogniced form (get|set)_attribute\n"; }
    unless(exists $self->{$attribute}){ croak "No such attribute '$attribute' exists in the class ", ref($self); }
    
    # Turn off strict references to enagle magic AUTOLOAD speedup
    no strict 'refs';
    
    # AUTOLOAD Accessors
    if($operation eq 'get'){
        # Define subroutine
        *{$AUTOLOAD} = sub { shift->{$attribute} };
    
    # AUTOLOAD Mutators
    }elsif($operation eq 'set'){
        # Define subroutine ...
        *{$AUTOLOAD} = sub { shift->{$attribute} = shift; };
        # ... and set the new attribute value.
        $self->{$attribute} = $newvalue;
    }
    
    # Turn strict references back on
    use strict 'refs';
    
    # Return the attribute value
    return $self->{$attribute};
    
}

sub DESTROY{
    my $self = @_;
}














=head1 AUTHOR

Hector Valverde, C<< <hvalverde at uma.es> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lwp-useragent-randomproxyconnect at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=LWP-UserAgent-RandomProxyConnect>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc LWP::UserAgent::RandomProxyConnect


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=LWP-UserAgent-RandomProxyConnect>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/LWP-UserAgent-RandomProxyConnect>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/LWP-UserAgent-RandomProxyConnect>

=item * Search CPAN

L<http://search.cpan.org/dist/LWP-UserAgent-RandomProxyConnect/>

=back


=head1 ACKNOWLEDGEMENTS

I thank the University of Malaga for being so incompetent and make me prove it. Obiously,
I am being ironic.

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Hector Valverde.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of LWP::UserAgent::RandomProxyConnect
