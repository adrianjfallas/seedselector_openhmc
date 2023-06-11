#!/usr/bin/env perl

use strict 'vars';
use warnings;

my $file = "merged_functional_coverage_summary.log";

open(LOG,"$file") or die "Can't open [$file]: $!\n";

my $testbench_top_module = "tb_top";
my $functional_cov_overall_average = 0;
my $functional_cov_overall_covered = 0;
my $functional_cov_points_covered = 0;
my $functional_cov_points_total = 0;

foreach my $line(<LOG>) {
   if($line =~ /$testbench_top_module\s+(\S+)%\s+(\S+)%\s+\((\d+)\/(\d+)\)/) {
      $functional_cov_overall_average = $1;
      $functional_cov_overall_covered = $2;
      $functional_cov_points_covered = $3;
      $functional_cov_points_total = $4;
   };
};

print "\n\n-----------------------------------------------------------------------------------------------------\n";
print "-----------------------------------------------------------------------------------------------------\n";
print " ╔═╗╦ ╦╦═╗╦═╗╔═╗╔╗╔╔╦╗  ╔═╗╦ ╦╔╗╔╔═╗╔╦╗╦╔═╗╔╗╔╔═╗╦    ╔═╗╔═╗╦  ╦╔═╗╦═╗╔═╗╔═╗╔═╗  ╦═╗╔═╗╔═╗╦ ╦╦ ╔╦╗╔═╗\n";
print " ║  ║ ║╠╦╝╠╦╝║╣ ║║║ ║   ╠╣ ║ ║║║║║   ║ ║║ ║║║║╠═╣║    ║  ║ ║╚╗╔╝║╣ ╠╦╝╠═╣║ ╦║╣   ╠╦╝║╣ ╚═╗║ ║║  ║ ╚═╗\n";
print " ╚═╝╚═╝╩╚═╩╚═╚═╝╝╚╝ ╩   ╚  ╚═╝╝╚╝╚═╝ ╩ ╩╚═╝╝╚╝╩ ╩╩═╝  ╚═╝╚═╝ ╚╝ ╚═╝╩╚═╩ ╩╚═╝╚═╝  ╩╚═╚═╝╚═╝╚═╝╩═╝╩ ╚═╝\n";
print "-----------------------------------------------------------------------------------------------------\n";
print "  testbench_top_module                = $testbench_top_module\n";
print "  functional_coverage_overall_average = $functional_cov_overall_average%\n";
print "  functional_coverage_overall_covered = $functional_cov_overall_covered%\n";
print "  functional_coverage_points_covered  = $functional_cov_points_covered\n";
print "  functional_coverage_points_total    = $functional_cov_points_total\n";
print "-----------------------------------------------------------------------------------------------------\n";
print "-----------------------------------------------------------------------------------------------------\n\n\n";

exit($functional_cov_overall_covered);
