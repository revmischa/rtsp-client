use 5.010000;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'AnyEvent::RTSP',
    VERSION_FROM      => 'lib/AnyEvent/RTSP.pm', # finds $VERSION
    PREREQ_PM         => {
        'AnyEvent::HTTP' => 0,
        'Moose' => 0,
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/AnyEvent/RTSP.pm', # retrieve abstract from module
       AUTHOR         => 'Mischa Spiegelmock <revmischa@cpan.org>') : ()),
);
