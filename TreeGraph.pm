package Tk::TreeGraph;

use strict;
use vars qw($VERSION @ISA);

use Carp ;
use Tk::Derived ;
use Tk::Canvas ;
use Tk::Frame;
use AutoLoader qw/AUTOLOAD/ ;


@ISA = qw(Tk::Derived Tk::Canvas);

$VERSION = sprintf "%d.%03d", q$Revision: 1.4 $ =~ /(\d+)\.(\d+)/;

Tk::Widget->Construct('TreeGraph');

sub InitObject
  {
    my ($dw,$args) = @_ ;

    # this should get a reasonable default ...
    my $defc = $dw->parent->cget('-foreground');
    $dw->ConfigSpecs
      (
       -shortcutColor => ['PASSIVE', undef, undef, 'orange'],
       -nodeColor     => ['PASSIVE', undef, undef, $defc],
       -arrowColor    => ['PASSIVE', undef, undef, $defc],
       -nodeTextColor => ['PASSIVE', undef, undef, $defc],
       -labelColor    => ['PASSIVE', undef, undef, $defc],
       # use this to tune the shape of nodes and arrows
       -arrowDeltaY   => ['PASSIVE', undef, undef, 40 ],
       -branchSeparation => ['PASSIVE', undef, undef, 120 ]
      );

    # bind button <1> on nodes to select a version
    $dw->bind ('node', 
               '<1>' => sub {$dw->toggleNode(color => 'blue')});

    $dw->SUPER::InitObject($args) ;


  }


1;

__END__



=head1 NAME

Tk::TreeGraph - Tk widget to draw a tree in a Canvas

=head1 SYNOPSIS

 use Tk ;
 use Tk::TreeGraph ;

 use strict ;

 my $mw = MainWindow-> new ;

 my $tg = $mw -> Scrolled('TreeGraph') ->pack(expand => 1, fill => 'both');

 $tg -> addLabel (text => 'some tree');

 my $ref = [1000..1005];
 my ($ox,$oy) = (100,100);

 $tg -> addNode 
  (
   nodeId => '1.0', 
   text => $ref, 
   xref => \$ox, 
   yref => \$oy
  ) ;

 my ($x,$y)= ($ox,$oy) ;
 $tg -> addDirectArrow
  (
   from => '1.0', 
   to => '1.1',
   xref => \$x,
   yref => \$y
  ) ;

 $tg->arrowBind
  (
   button => '<1>',
   color => 'orange',
   command =>  sub{my %h = @_;
                   warn "clicked 1 arrow $h{from} -> $h{to}\n";}
  );

 $tg->nodeBind
  (
   button => '<2>',
   color => 'red',
   command => sub {my %h = @_;
                   warn "clicked 2 node $h{nodeId}\n";}
  );

 $tg->command( on => 'arrow', label => 'dummy 2', 
                 command => sub{warn "arrow menu dummy2\n";});

 $tg->arrowBind(button => '<3>', color => 'green', 
              command => sub{$tg->popupMenu(@_);});

 $tg->command(on => 'node', label => 'dummy 1', 
                 command => sub{warn "node menu dummy1\n";});

 $tg->nodeBind(button => '<3>', color => 'green', 
              command => sub{$tg->popupMenu(@_);});

 MainLoop ; # Tk's

=head1 DESCRIPTION

Tk::TreeGraph is a Canvas specialized to draw trees on a Canvas using
arrows and nodes. A node is simply some text imbedded in a rectangular shape.

TreeGraph is able to draw the following items:

=over 4

=item *

node: some text in a rectangular shape.

=item *

direct arrow: an arrow to go from one node to the following one.

=item *

slanted arrow: an arrow to make a new branch.

=item *

shortcuts arrow: an arrow to represent a shortcut between 2 nodes from
different branches.

=back

GraphMgr also provides :

=over 4

=item *

a binding on nodes on button 1 to 'select' them.

=item *

Methods to bind nodes and arrows on user's call-back.

=back

=head1 CAVEATS

You might say that the tree is a weird tree since it is drawn downward
and assymetric and adding branches leaves a lot of void between
the them.

You'd be right. I'm not a specialist in tree drawing algorithms but
the crude algorithm used here works quite fine with drawing id trees
for VCS system. But as usual, I'm always listening for suggestions or
even better, patches ;-) .

=head1 Widget Options

=over 4

=item *

-nodeColor: Color of the node rectangle.

=item *

-nodeTextColor: Color of the text within the nodes

=item *

-labelColor

=item *

-arrowColor

=item *

-shortcutColor: Color of the shortcut arrow (default 'orange')

=item *

-arrowDeltaY: length of direct arrows (downward). default 40

=item *

-branchSeparation: minimum width between 2 branches of the tree (default 120) 

=back

=cut

#'

=head1 Drawing Methods added to Canvas

In each drawing methods, passing a reference (here x_ref, y_ref and 
delta_x_ref) means that the value refered to will be modified by the
method.

Note that all id parameters as treated as string.

=head2 addDirectArrow()

=over 4

=item *

from: node id where the arrow starts

=item *

to: node id where the arrow ends

=item *

xref: \$x

=item *

yref: \$y

=back

Add a new straight (i.e. vertical) arrow starting from coordinate (x,y).

x and y are modified so that their new value is the coordinate of the tip
of the arrow.

=head2 addSlantedArrow()

Parameters are:

=over 4

=item *

from: node id where the arrow starts

=item *

to: node id where the arrow ends

=item *

xref: x_ref


=item *

yref: y_ref

=item *

deltaXref: \$dx

=back

Add a new branch connecting node 'id' to node 'id2'.

The arrow will be drawn from (x,y) to (x+delta_x, y).

x and y are modified so that their new value is the coordinate of the tip
of the arrow.

delta_x is modified so that the next branch drawn from node 'id1' 
using this delta_x variable will not overlap the first branch.

=head2 addLabel()

Put some text on the top of the graph.

=over 4

=item *

text: text to be inserted on the top of the graph.

=back

=head2 addShortcutInfo()

=over 4

=item *

from: node id where the arrow starts

=item *

to: node id where the arrow ends

=back

Declare that a shortcut arrow will be drawn from node 'arrow_start' and 
'arrow_end'.

=head2 addAllShortcuts()

This method is to be called once all nodes, direct arrow and branch arrows
are drawn and all relevant calls to addShortcutInfo are done.
 
It will draw shortcut arrows between the ids declared with 
the addShortcutInfo method.

=head2 addNode()

=over 4

=item *

nodeId: id

=item *

text: text array ref. This text will be written inside the rectangle

=item *

xref: \$x


=item *

yref: \$y)

=back

Will add a new node (made of a rectangle with the text inside). The node
will be drawn at coordinate (x,y)

x and y are modified so that their new value is the coordinate of the tip
of the arrow.

Note that this method will add the nodeId on top of the text.

=head2 clear()

Clear the graph.

=head1 Management methods

=head2 nodeBind()

=over 4

=item *

button: button name to bind (e.g. '<1>') 

=item *

color: color of the node when it is clicked on.

=item *

command: sub ref 

=back

Bind the 'button' on all nodes. When 'button' is clicked, the node
text color will change to 'color' and the callback sub will be called
with these parameters: 

 (on => 'node', nodeId => $nodeId)

=head2 arrowBind()

=over 4

=item *

button: button name to bind (e.g. '<1>') 

=item *

color: color of the node when it is clicked on.

=item *

command: sub ref 

=back

Bind the 'button' on arrows. When 'button' is clicked, the arrow color will
change to 'color' and the callback sub will be called with these parameters:

 (
   on   => 'arrow', 
   from => nodeId_on_arrow_start, 
   to   => nodeId_on_arrow_tip
 ) 

=head2 unselectAllNodes()

Unselect all previously selected nodes (see button <1> binding)

=head2 getSelectedNodes()

Return an array containing nodeIds of all nodes currently selected.

=head2 command()

This will add a new entry on a Popup menu which can be raised on a node
or an arrow.

Parameters are :

=over 4

=item *

on: either 'node' or 'arrow'

=item *

label: Label of the Popup menu entry

=item *

command: sub ref runned when the menu is invoked

=back

The callback will be invoked with these parameters when the command is
set for B<nodes> :

 (on => 'node', nodeId => $nodeId)

The callback will be invoked with these parameters when the command is
set for B<arrows> :

 (
   on   => 'arrow', 
   from => nodeId_on_arrow_start, 
   to   => nodeId_on_arrow_tip
 ) 


=head1 Private methods

These functions are documented only for people wanting to improve or
inherit this widget.

=head2 setArrow()

=over 4

=item *

color: color of the arrow when selected.

=back

Reset any previously selected arrow to default color and set the current 
arrow to the color. This function should be used with a bind.

Returns (from => $endNodeId, to => $tipNodeId) to specify the nodes 
the arrow is attached to.

=head2 setNode()

=over 4

=item *

color: color of the arrow when selected.

=item *

nodeId: nodeId to select (optional, default to the node under the mouse 
pointer)

=back

Set node either from passed nodeId or from the mouse pointer.
When a node is set, only the text is highlighted

Returns the nodeId of the current node (i.e. the node clicked by the user
if this function was used in a bind)

=head2 toggleNode()

=over 4

=item *

color: color of the arrow when selected.

=item *

nodeId: nodeId to select (optional, default to the node under the mouse 
pointer)

=back

Will toggle the node rectangle between 'color' and default.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998-1999 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Tk::Canvas(3)

=cut

## General functions

sub clear
  {
    my $dw = shift ;
    delete $dw->{graph} ;
    $dw-> clear() ;
    $dw->configure(scrollregion => [0,0, 1000 , 400 ])
  }

sub addLabel
  {
    my $dw = shift ;
    my %args = @_ ;
    my $text = $args{text} ;
    
    my $defc = $dw->cget('-labelColor') ;
    $dw->create('text', '7c' , 5 , anchor => 'n' , fill => $defc,
                               text=> $text, justify => 'center') ;
  }

## Arrow functions

# add a an arrow for a regular revision, return the new $$yr at the bottom of
# the arrow
sub addDirectArrow
  {
    my $dw = shift ;
    my %args = @_ ;
    my $nodeId = $args{from} ;
    my $lowerNodeId =  $args{to} ;
    my $xr = $args{xref} ;
    my $yr = $args{yref} ;

    my $old_y = $$yr;
    my $arrow_dy = $dw->cget('-arrowDeltaY');
    $$yr = $old_y + $arrow_dy ; # give length of arrow

    my $defc = $dw->cget('-arrowColor'); 
    my $itemId = $dw->create('line', $$xr, $old_y, $$xr, $$yr , 
                             fill => $defc,
                             qw(-arrow last -tags arrow)); 

    $dw->{arrow}{start}{$itemId} = $nodeId ; 
    $dw->{arrow}{tip}{$itemId} = $lowerNodeId ; 

  }

 # will call-back sub with ($start_nodeId,$tip_nodeId) nodeId 
sub arrowBind 
  { 
    my $dw = shift ; 
    my %args = @_ ; 
    my $button = $args{button} ; 
    my $color = $args{color} ; 
    my $callback = $args{command} ;

    # bind button <1> on arrows to display history information
    $dw->bind
      (
       'arrow', $button => sub 
       {
         my @ids = $dw->setArrow(color => $color) ;
         $dw->idletasks;
         &$callback(on => 'arrow', @ids) ;
       });

    $dw->bind
      (
       'scutarrow', $button => sub 
       {
         my @ids = $dw->setArrow(color => $color) ;
         $dw->idletasks;
         &$callback(on => 'arrow',@ids) ;
       });
  }

# will return with ($start_revision,$tip_revison) rev numbers
# setArrow
sub setArrow
  {
    my $dw = shift ;
    my %args = @_ ;
    my $color = $args{color} ;
    
    # reset any selected arrow
    if (defined $dw->{graph}{oldArrow})
      {
        my $tag = $dw->gettags($dw->{graph}{oldArrow});
        my $defc = $tag eq 'scutarrow'? 
          $dw->cget('-shortcutColor') :  $dw->cget('-arrowColor');

        $dw->itemconfigure($dw->{graph}{oldArrow}, fill => $defc);
      }

    my $itemId = $dw->find('withtag' => 'current');
    $dw->{graph}{oldArrow} = $itemId ;
    $dw->itemconfigure($itemId, fill => $color) ;
    my $tipNodeId = $dw->{arrow}{tip}{$itemId} ;
    my $endNodeId = $dw->{arrow}{start}{$itemId} ;

    return (from => $endNodeId, to => $tipNodeId) ;
  }

## Slanted Arrows

sub addSlantedArrow
  {
    my $dw = shift ;
    my %args = @_ ;
    my $nodeId = $args{from} ;
    my $branch =  $args{to} ;
    my $xr = $args{xref} ;
    my $yr = $args{yref} ;
    my $dxr = $args{deltaXref} ; # must be undef or null for first branch

    my $branch_dx= $dw->cget('-branchSeparation');

    $$dxr = 0 unless defined $dxr ;
    $$dxr += $branch_dx  ;

    my $old_x = $$xr ;
    my $old_y = $$yr ;

    my $arrow_dy = $dw->cget('-arrowDeltaY');
    $$yr += $arrow_dy ; # give length of arrow
    $$xr += $$dxr ;

    my $defc = $dw->cget('-arrowColor');
    my $itemId = $dw->create('line', $old_x, $old_y, 
                         $$xr, $$yr,   fill => $defc,
                         qw(arrow last tags arrow));


    $dw->{arrow}{start}{$itemId} = $nodeId ;
    $dw->{arrow}{tip}{$itemId} = $branch ;
  }

## Short Cut Arrows 

sub addShortcutInfo
  {
    my $dw = shift ;
    my %args = @_ ;
    my $nodeId = $args{from} ;
    my $mNodeId = $args{to} ;
    $dw->{graph}{shortcutFrom}{$nodeId} = $mNodeId ;
  }

sub addAllShortcuts
  {
    my $dw = shift ;

    my $color = $dw->cget('-shortcutColor') || $dw->cget('-foreground');

    foreach my $nodeId (keys %{$dw->{graph}{shortcutFrom}})
      {
        my $mNodeId = $dw->{graph}{shortcutFrom}{$nodeId} ;
        next unless defined $dw->{graph}{bottomCoord}{$mNodeId} ;
        my ($x, $y) = @{$dw->{graph}{bottomCoord}{$mNodeId}} ;
        my ($dx, $dy) = @{$dw->{graph}{topCoord}{$nodeId}} ;
        my $itemId = $dw->create('line', $x, $y, $dx, $dy,  
               'arrow' => 'last', 'tag' => 'scutarrow','fill'=>$color);
        $dw->{arrow}{start}{$itemId} = $mNodeId ;
        $dw->{arrow}{tip}{$itemId} = $nodeId ;
      }
  }

## Node functions

# draw a node, return the y coord of the bottom of the node 
#($x does not change)
sub addNode
  {
    my $dw = shift ;
    my %args = @_ ;
    my $nodeId = $args{nodeId} ;
    my $textArrayRef = $args{text} ;
    my $xr = $args{xref} ;
    my $yr = $args{yref} ;

    # compute x coord 
    # find lower node and call addNode

    $dw->{node}{top}{$nodeId} = [ $$xr, $$yr] ; # top of node text
    my $oldy = $$yr ;

    $$yr += 5 ; # give some breathing space 

    my $text = join ("\n", $nodeId, @$textArrayRef)."\n";

    # compute y coord
    # draw node
    my $defc = $dw->cget('-nodeTextColor');

    my $tid = $dw->create('text', $$xr, $$yr, text=>$text,  fill => $defc,
                          qw/justify center anchor n width 12c tags node/) ;

    $$yr += 14 * (1+ scalar(@$textArrayRef)) + 10 ;

    my $branch_dx= $dw->cget('-branchSeparation');

    $defc = $dw->cget('-nodeColor');
    my $rid = $dw->create('rectangle',
                          $$xr - $branch_dx/2 + 10 , $oldy,
                          $$xr + $branch_dx/2 - 10 , $$yr,
                          -outline => $defc, width => 2 , tags => 'node'
                        ) ;

    $dw -> {nodeId}{$tid}=$nodeId ; 
    $dw -> {nodeId}{$rid}=$nodeId ; # also stored
    $dw -> {node}{text}{$nodeId}=$tid ;
    $dw -> {node}{rectangle}{$nodeId}=$rid ;

    $dw->{node}{bottom}{$nodeId} = [ $$xr, $$yr] ; # bottom of node text

    # must initialize myself the scrollregion for the first time
    my $array = $dw->cget('scrollregion') || [0,0, 200, 200];

    my $incx = $array->[2] < $$xr ? 200 : 0 ;
    my $incy = $array->[3] < $$yr ? 200 : 0 ;

    if ($incx>0 or $incy>0)
      {
        my $newx = $array->[2] + $incx ;
        my $newy = $array->[3] + $incy ;
        $dw->configure(scrollregion => [0,0, $newx , $newy ])
      }
  }

# will return with node Id
# when toggling a node, only the rectangle is highlighted
sub toggleNode
  {
    my $dw = shift ;
    my %args = @_ ;
    my $color = $args{color} ;
    my $nodeId = $args{nodeId} || $dw->getCurrentNodeId; # optional

    my $rid = $dw->{node}{rectangle}{$nodeId} ; # retrieve id of rectangle

    if (defined $dw->{node}{selected}{$nodeId})
      {
        my $defc = $dw->cget('-foreground');
        $dw->itemconfigure($rid, outline => $defc) ; #unselect
        delete $dw->{node}{selected}{$nodeId} ;
      } 
    else
      {
        die "Error no color specified while selecting node\n"
          unless defined $color ;
        $dw->itemconfigure($rid, outline => $color) ;
        $dw->{node}{selected}{$nodeId} = $rid ; # store id of rectangle
      } 

    $dw->idletasks;
    return $nodeId ;
  }

sub getSelectedNodes
  {
    my $dw = shift ;
    return keys %{$dw->{node}{selected}} ;
  }

sub unselectAllNodes
  {
    my $dw = shift ;

    foreach my $itemId (values %{$dw->{graph}{selected}})
      {
        $dw->toggleNode(itemId => $itemId);
      }
  }

sub getCurrentNodeId
  {
    my $dw = shift ;

    my $selected = $dw->find('withtag' => 'current');
        
    unless (defined $selected)
      {
        $dw->bell ;
        return undef ;
      }
        
    unless (defined $selected)
      {
        $dw->bell ; $dw->bell ; # twice for debug ...
        return undef ;
      }

    return $dw->{nodeId}{$selected} ;
  }

# set node either from passed nodeId or from the mouse pointer
# when a node is set, only the text is highlighted
sub setNode
  {
    my $dw = shift ;
    my %args = @_ ;
    my $color = $args{color} ;
    my $nodeId = $args{nodeId} || $dw->getCurrentNodeId ; # optional

    if (defined $dw->{graph}{oldNode})
      {
        my $defc = $dw->cget('-nodeTextColor') || $dw->cget('-foreground');
        $dw->itemconfigure($dw->{graph}{oldNode},fill => $defc);
      }

    my $itemId = $dw->{node}{text}{$nodeId} ;
    $dw->{graph}{oldNode} = $itemId ;
    $dw->itemconfigure($itemId, fill => $color) ;

    return $dw->{nodeId}{$itemId} ;
  }


# will call-back sub with node $rev
sub nodeBind
  {
    my $dw = shift ;
    my %args = @_ ;
    my $color = $args{color} ;
    my $button = $args{button} ;
    my $callback = $args{command} ;

    $dw->bind
      (
       'node', $button => sub 
       {
         my $id = $dw->setNode(color => $color) ;
         $dw->idletasks;
         &$callback(on => 'node', nodeId => $id) ;
       });

  }

## Popup menu commands

# will call-back sub with ($start_nodeId,$tip_nodeId) node Ids
sub command
  {
    my $dw = shift ;
    my %args = @_ ;
    my $on = $args{on};
    my $label = $args{label} ;
    my $sub = $args{command} ;
    
    $dw->{command}{$on}{$label} = $sub ;
  }

sub popupMenu
  {
    my $dw = shift ;
    my %args = @_ ;
    my $on = delete $args{on} ;

    my $menu = $dw-> Menu; 
    foreach (keys %{$dw->{command}{$on}})
      {
        my $s = $dw->{command}{$on}{$_};
        $menu -> add 
          (
           'command',
           '-label' => $_, 
           '-command' => sub {&$s(%args) ;}
          );
      }

    $menu->Popup(-popover => 'cursor', -popanchor => 'nw');
  }

