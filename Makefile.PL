use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Business::PL::PESEL',
    VERSION_FROM      => 'lib/Business/PL/PESEL.pm', # finds $VERSION
    PREREQ_PM         => {
                             Time::Piece => 0,
                         }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Business/PL/PESEL.pm', # retrieve abstract from module
       AUTHOR         => 'A. U. Thor <xenu@>') : ()),
);
