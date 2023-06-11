#!/usr/bin/env perl

use strict 'vars';
use warnings;

my $file = "xrun.log";

open(LOG,"$file") or die "Can't open [$file]: $!\n";

foreach my $line(<LOG>) {
   if($line =~ /UVM_FATAL.*SEED_SELECTOR\: DISCARDED/) {
      #$functional_cov_overall_average = $1;
      #$functional_cov_overall_covered = $2;
      #$functional_cov_points_covered = $3;
      #$functional_cov_points_total = $4;
      print "\n\n-----------------------------------------------------------------------------------------------------\n";
      print "-----------------------------------------------------------------------------------------------------\n";
      print "╔╦╗╦╔═╗╔═╗╔═╗╦═╗╔╦╗╔═╗╔╦╗  ╔╗ ╦ ╦  ╔═╗╔═╗╔═╗╔╦╗  ╔═╗╔═╗╦  ╔═╗╔═╗╔╦╗╔═╗╦═╗\n";
      print " ║║║╚═╗║  ╠═╣╠╦╝ ║║║╣  ║║  ╠╩╗╚╦╝  ╚═╗║╣ ║╣  ║║  ╚═╗║╣ ║  ║╣ ║   ║ ║ ║╠╦╝\n";
      print "═╩╝╩╚═╝╚═╝╩ ╩╩╚══╩╝╚═╝═╩╝  ╚═╝ ╩   ╚═╝╚═╝╚═╝═╩╝  ╚═╝╚═╝╩═╝╚═╝╚═╝ ╩ ╚═╝╩╚═\n";
      ##print "-----------------------------------------------------------------------------------------------------\n";
      ##print "  testbench_top_module                = $testbench_top_module\n";
      ##print "  functional_coverage_overall_average = $functional_cov_overall_average%\n";
      ##print "  functional_coverage_overall_covered = $functional_cov_overall_covered%\n";
      ##print "  functional_coverage_points_covered  = $functional_cov_points_covered\n";
      ##print "  functional_coverage_points_total    = $functional_cov_points_total\n";
      print "-----------------------------------------------------------------------------------------------------\n";
      print "-----------------------------------------------------------------------------------------------------\n\n\n";
      exit 7;
   };
};

exit 0;
