package Tk::TreeGraph;

use strict;
use vars qw($VERSION @ISA);

use Carp ;
use Tk::Derived ;
use Tk::Canvas ;
use Tk::Frame;
use AutoLoader qw/AUTOLOAD/ ;


@ISA = qw(Tk::Derived Tk::Canvas);

$VERSION = sprintf "%d.%03d", q$Revision: 1.10 $ =~ /(\d+)\.(\d+)/;

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
       -branchSeparation => ['PASSIVE', undef, undef, 120 ],
       -x_start       => ['PASSIVE', undef, undef, 100 ],
       -y_start       => ['PASSIVE', undef, undef, 100 ]
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

 my $ref = [qw/some really_silly text/];

 $tg -> addNode 
  (
   nodeId => '1.0', 
   text => $ref
  ) ;

 # EITHER add the arrow and the node
 $tg -> addDirectArrow
  (
   from => '1.0', 
   to => '1.1'
  ) ;

 $tg->addNode
  (
   nodeId => '1.1',
   text => ['some','text']
  ) ;

 # OR add a node after another one, in this case the widget 
 # will draw the arrow
 $tg->addNode
  (
   after =>'1.0',
   nodeId => '1.1',
   text => ['some','text']
  );

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

Note that the tree MUST be drawn from top to bottom and from left to
right. Unless you may get a very confusing drawing of a tree.

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

=item *

-x_start: x coordinate of the root of the tree. (default 100)

=item *

-y_start: y coordinate of the root of the tree.(default 100)

=back

=cut

=head1 Drawing Methods added to Canvas

You draw the tree node after node with addNode using the 'after' 
parameter. Then the object will infer the kind of arrow needed between the
2 nodes. Using the 'after' parameter, you no longer need
to call youself the addSlantedArrow or addDirectArrow methods.

=head2 addNode(...)

=over 4

=item *

nodeId: string to identify this node.

=item *

text: text array ref. This text will be written inside the rectangle

=item *

after: Either a [x,y] array ref setting the coordinate of the root
of the tree (this can be used to draw the a first tree in the canvas and/or
to draw a second tree in the canvas). If after is a nodeId, an arrow
(direct or slanted) will be drawn from the 'after' node to this new node.

=back

Will add a new node (made of a rectangle with the text inside). 

Note that this method will add the nodeId on top of the passed text
('text' parameter).

=head2 addDirectArrow(...)

You can use this method if you want to change the default aspect of
the direct arrow. In this case do not use the 'after' parameter of the
addNode() method.

=over 4

=item *

from: node id where the arrow starts

=item *

to: node id where the arrow ends

=back

Add a new straight (i.e. vertical) arrow starting from a node. Note that
the 'from' nodeId must be defined. The 'to' nodeId must NOT be defined.
(Remember that you must draw the tree from top to bottom)

=head2 addSlantedArrow(...)

You can use this method if you want to change the default aspect of
the slanted arrow. In this case do not use the 'after' parameter of the
addNode() method.

Parameters are:

=over 4

=item *

from: node id where the arrow starts

=item *

to: node id where the arrow ends

=back

Add a new branch connecting node 'id' to node 'id2'.  Note that the
'from' nodeId must be defined. The 'to' nodeId must NOT be defined.
(Remember that you must draw the tree from left to right)

=head2 addLabel(...)

Put some text on the top of the graph.

=over 4

=item *

text: text to be inserted on the top of the graph.

=back

=head2 addShortcutInfo(...)

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

=head2 clear()

Clear the graph.

=head1 Management methods

=head2 nodeBind(...)

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

=head2 arrowBind(...)

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

=head2 command(...)

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

=head2 setArrow(...)

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

=head2 toggleNode(...)

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

## data structures (i.e $dw->{...})

# arrow -> start -> hash : key is arrow widget id, 
#                          value is node Id where the arrow starts
# arrow -> tip   -> hash : key is arrow widget id, 
#                          value is node Id where the arrow ends

# node -> top       : [x,y] : coordinates of the top of the rectangle
# node -> bottom    : [x,y] : coordinates of the bottom of the rectangle
# node -> text      : text widget ref
# node -> rectangle : rectangle widget ref

# nodeId->hash ref: key is text or rectangle widget id, value: nodeId

# tset -> hash ref : (toggle set) key is nodeId set by the user, value is
#                    the rectangle widget id

# xset -> arrow: (eXclusive set) : arrow widget id of the arrow set by the user
# xset -> node : (eXclusive set) : nodeId of the node set by the user

# shortcutFrom -> hash : key is the nodeId of the start of the shortcut,
#                        value is the nodeId of the end of the shortcut

## General functions

sub clear
  {
    my $dw = shift ;
    
    foreach (qw/arrow node nodeId tset xset shortcutFrom/)
      {
        delete $dw->{$_};
      }

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

    $dw->{after}{$nodeId}=1;
    my $x = $dw->{x} ;
    my $y = $dw->{y};

    $dw->BackTrace("AddSlantedArrow: unknown 'from' nodeId: $nodeId\n")
      unless defined $dw->{node}{bottom}{$nodeId};

    my $old_x = $x = $dw->{node}{bottom}{$nodeId}[0];
    my $old_y = $y = $dw->{node}{bottom}{$nodeId}[1];

    my $arrow_dy = $dw->cget('-arrowDeltaY');
    $y = $old_y + $arrow_dy ; # give length of arrow

    my $defc = $dw->cget('-arrowColor'); 
    my $itemId = $dw->create('line', $x, $old_y, $x, $y , 
                             fill => $defc,
                             qw(-arrow last -tags arrow)); 

    $dw->{arrow}{start}{$itemId} = $nodeId ; 
    $dw->{arrow}{tip}{$itemId} = $lowerNodeId ; 

    $dw->{x} = $x;
    $dw->{y} = $y ;
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
    if (defined $dw->{xset}{arrow})
      {
        my $tag = $dw->gettags($dw->{xset}{arrow});
        my $defc = $tag eq 'scutarrow'? 
          $dw->cget('-shortcutColor') :  $dw->cget('-arrowColor');

        $dw->itemconfigure($dw->{xset}{arrow}, fill => $defc);
      }

    my $itemId = $dw->find('withtag' => 'current');
    $dw->{xset}{arrow} = $itemId ;
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
    my $x = $dw->{x};
    my $y = $dw->{y} ;

    my $sx = $dw->{slanted_x} || $dw->cget('-x_start');

    my $branch_dx= $dw->cget('-branchSeparation');

    $sx += $branch_dx  ;

    $dw->BackTrace("AddSlantedArrow: unknown 'from' nodeId: $nodeId\n")
      unless defined $dw->{node}{bottom}{$nodeId};

    my $old_x = $x = $dw->{node}{bottom}{$nodeId}[0];
    my $old_y = $y = $dw->{node}{bottom}{$nodeId}[1];

    my $arrow_dy = $dw->cget('-arrowDeltaY');
    $y += $arrow_dy ; # give length of arrow
    $x = $sx ;

    my $defc = $dw->cget('-arrowColor');
    my $itemId = $dw->create('line', $old_x, $old_y, 
                             $x, $y,   fill => $defc,
                             qw(arrow last tags arrow));

    $dw->{arrow}{start}{$itemId} = $nodeId ;
    $dw->{arrow}{tip}{$itemId} = $branch ;

    $dw->{x} = $x;
    $dw->{y} = $y ;
    $dw->{slanted_x} = $sx;
  }

## Short Cut Arrows 

sub addShortcutInfo
  {
    my $dw = shift ;
    my %args = @_ ;
    my $nodeId = $args{from} ;
    my $mNodeId = $args{to} ;

    $dw->BackTrace("addShortcutInfo: unknown 'from' nodeId: $nodeId\n")
      unless defined $dw->{node}{bottom}{$nodeId};

    $dw->BackTrace("addShortcutInfo: unknown 'to' nodeId: $mNodeId\n")
      unless defined $dw->{node}{top}{$mNodeId};

    $dw->{shortcutFrom}{$nodeId} = $mNodeId ;
  }

sub addAllShortcuts
  {
    my $dw = shift ;

    my $color = $dw->cget('-shortcutColor') || $dw->cget('-foreground');

    foreach my $nodeId (keys %{$dw->{shortcutFrom}})
      {
        my $mNodeId = $dw->{shortcutFrom}{$nodeId} ;
        next unless defined $dw->{node}{bottom}{$mNodeId} ;
        my ($bx, $by) = @{$dw->{node}{bottom}{$nodeId}} ; # beginning of arrow
        my ($ex, $ey) = @{$dw->{node}{top}{$mNodeId}} ; # end of arrow
        my $itemId = $dw->create('line', $bx, $by, $ex, $ey,  
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

    my $after = $args{after};
    if (defined $after)
      {
        if (ref($after) eq 'ARRAY')
          {
            # re-start another tree
            ($dw->{x},$dw->{y}) = @$after;
            $dw->{slanted_x} = $dw->{x};
          }
        elsif (defined $dw->{after}{$after})
          {
            $dw->addSlantedArrow('from' => $after, to => $nodeId);
          }
        else
          {
            $dw->addDirectArrow('from' => $after, to => $nodeId);
          }
      }

    my $x = $dw->{x} || $dw->cget('-x_start');
    my $y = $dw->{y} || $dw->cget('-y_start');

    # compute x coord 
    # find lower node and call addNode

    $dw->{node}{top}{$nodeId} = [ $x, $y] ; # top of node text

    my $oldy = $y ;
    $y += 5 ; # give some breathing space 

    my $text = join ("\n", $nodeId, @$textArrayRef)."\n";

    # compute y coord
    # draw node
    my $defc = $dw->cget('-nodeTextColor');

    my $tid = $dw->create('text', $x, $y, text=>$text,  fill => $defc,
                          qw/justify center anchor n width 12c tags node/) ;

    $y += 14 * (1+ scalar(@$textArrayRef)) + 10 ;

    my $branch_dx= $dw->cget('-branchSeparation');

    $defc = $dw->cget('-nodeColor');
    my $rid = $dw->create('rectangle',
                          $x - $branch_dx/2 + 10 , $oldy,
                          $x + $branch_dx/2 - 10 , $y,
                          -outline => $defc, width => 2 , tags => 'node'
                        ) ;

    $dw -> {nodeId}{$tid}=$nodeId ; 
    $dw -> {nodeId}{$rid}=$nodeId ; # also stored
    $dw -> {node}{text}{$nodeId}=$tid ;
    $dw -> {node}{rectangle}{$nodeId}=$rid ;

    $dw->{node}{bottom}{$nodeId} = [ $x, $y] ; # bottom of node text

    # must initialize myself the scrollregion for the first time
    my $array = $dw->cget('scrollregion') || [0,0, 200, 200];
    my $mod = 0;

    if ($array->[2] < $x + $branch_dx)
      {
        $array->[2] = $x + $branch_dx ;
        $mod = 1;
      }

    if ($array->[3] < $y)
      {
        $array->[3] = $y + 50 ; # some margin
        $mod = 1;
      }

    $dw->configure(scrollregion => $array) if $mod ;

    $dw->{x} = $x;
    $dw->{y} = $y ;
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

    if (defined $dw->{tset}{node}{$nodeId})
      {
        my $defc = $dw->cget('-foreground');
        $dw->itemconfigure($rid, outline => $defc) ; #unselect
        delete $dw->{tset}{node}{$nodeId} ;
      } 
    else
      {
        die "Error no color specified while selecting node\n"
          unless defined $color ;
        $dw->itemconfigure($rid, outline => $color) ;
        $dw->{tset}{node}{$nodeId} = $rid ; # store id of rectangle
      } 

    $dw->idletasks;
    return $nodeId ;
  }

sub getSelectedNodes
  {
    my $dw = shift ;
    return keys %{$dw->{tset}{node}} ;
  }

sub unselectAllNodes
  {
    my $dw = shift ;

    my $defc = $dw->cget('-foreground');
    foreach (values %{$dw->{tset}{node}})
      {
        $dw->itemconfigure($_, outline => $defc) ; #unselect
      }
    delete $dw->{tset}{node} ;
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

    if (defined $dw->{xset}{node})
      {
        my $defc = $dw->cget('-nodeTextColor') || $dw->cget('-foreground');
        $dw->itemconfigure($dw->{xset}{node},fill => $defc);
      }

    my $itemId = $dw->{node}{text}{$nodeId} ;
    $dw->{xset}{node} = $itemId ;
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

