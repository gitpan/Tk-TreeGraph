use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   'NAME'	=> 'Tk::TreeGraph',
   'VERSION_FROM' => 'TreeGraph.pm',
   'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
   ($] >= 5.005 ?
    (ABSTRACT   => 'Widget to draw a tree in a Canvas',
     AUTHOR     => 'Dominique Dumont (domi@barrayar.grenoble.hp.com)') : ())
);
