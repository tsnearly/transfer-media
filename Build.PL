use strict;
use warnings;
use Module::Build;

# NOTE: This Build.PL is to make it easier for people without dzil
# to install dependencies/etc. It may be out of sync with dist.ini
# and dist_version needs to be manually updated, for now.

my $builder = Module::Build->new(
    module_name         => 'Media: Management',
    license             => 'perl',
    dist_author         => 'Tony Snearly <seetigerlearn@gmail.com>',
    dist_abstract       => 'Media Files AutoManager',
    dist_version        => 'lib/Media/Management.pm',
    include_dirs        => '',
    build_requires => {
        'Test::More'      => 0,
        'Test::Exception' => 0,
    },
    configure_requires => { 'Module::Build' => 0.38 },
    requires => {
        'perl'            => '5.008',
    },
    add_to_cleanup      => [ 'Media-Management-*' ],
    meta_merge     => {
        resources => {
            repository  => 'https://github.com/tsnearly/transfer-media/tree/master'
        },
    },
);

$builder->create_build_script();
print "Have a great day!\n";
