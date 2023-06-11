#!/usr/bin/env perl

use strict 'vars';
use warnings;

my $file = "merged_functional_coverage_detailed.log";

#Instance name: tb_top.axi4_hmc_req_if
#Type name: axi4_stream_if
#File name: /nis/asic/cr_dump2/fallasad/SeedSelector_OpenHMC/seedselector_openhmc/sim/UVC/axi4_stream/sv/axi4_stream_if.sv
#Include Files:
#    /nis/asic/cr_dump2/fallasad/SeedSelector_OpenHMC/seedselector_openhmc/sim/UVC/axi4_stream/sv/axi4_stream_if.sv
#Number of covered cover bins: 119 of 1205
#Number of uncovered cover bins: 1086 of 1205
#
#Name                           Average, Covered Grade         Line  Source Code
#---------------------------------------------------------------------------------------------------
#axi4                           47.73%, 9.88% (119/1205)       82 (axi4_stream_if.sv) covergroup axi4_cg @ (posedge ACLK);
#|--T_VALID                     100.00% (2/2)                  84 (axi4_stream_if.sv) T_VALID : coverpoint TVALID;
#| |--auto[0]                   100.00% (60085/1)              84 (axi4_stream_if.sv) T_VALID : coverpoint TVALID;
#| |--auto[1]                   100.00% (1521/1)               84 (axi4_stream_if.sv) T_VALID : coverpoint TVALID;
#|--T_READY                     100.00% (2/2)                  85 (axi4_stream_if.sv) T_READY : coverpoint TREADY;
#| |--auto[0]                   100.00% (42/1)                 85 (axi4_stream_if.sv) T_READY : coverpoint TREADY;
#| |--auto[1]                   100.00% (61563/1)              85 (axi4_stream_if.sv) T_READY : coverpoint TREADY;

open LOG, "$file" or die "Can't open [$file]: $!\n";
my @lines = <LOG>;
close LOG;

print "`include \"seed_selector/cov_tree_defs_and_methods.sv\"\n\n";
print "function int build_base_covmodel_tree(int influence_param_1);\n\n";
print "\tstring s;\n";
print "\tint base_tree_weight;\n";
print "\tint seed_tree_weight;\n";
print "\tint seed_selector_result;\n";
print "\tTreeNode base_covermodel;\n";

my $instance_name;
my $instance_found= 0;
my $instance_begin= 0;
my $instance_end= 0;

my $cover_item_number=1;
my $cover_item_name;
my $cover_item_functional_cov_overall_covered = 0;
my $cover_item_functional_cov_points_covered = 0;
my $cover_item_functional_cov_points_total = 0;

my $cover_group_number=0;
my $cover_point_number=0;
my $cover_value_number=0;

#First define the TreeNode handlers
foreach my $line(@lines) {
   #Find start of instance
   if($line =~ /Instance\sname:\s(\S+)/) {
      $instance_name = $1;
   };
   if($instance_found) {
      $instance_found = 0;
      $instance_begin = 1;
      $instance_end = 0;
      #Division line
      next
   };
   if($line =~ /Name.*Covered/) {
      $instance_found = 1;
      $instance_begin = 0;
      $instance_end = 1;
   };
   if($instance_begin and !$instance_end) {

      #Covergroups
      #Regexp example
      #axi4                           47.73%, 9.88% (119/1205)       82 (axi4_stream_if.sv) covergroup axi4_cg @ (posedge ACLK);
      if($line =~ /(\S+)\s+(\S+)%,\s+(\S+)%\s+\((\d+)\/(\d+)\).*covergroup/) {
         $cover_item_name = $1;
         print "\tTreeNode base_covergroup_${cover_group_number};\n";
         $cover_group_number++;
         $cover_item_number++;
      };

      #Coverpoints
      #Regexp example
      #|--T_VALID                     100.00% (2/2)                  84 (axi4_stream_if.sv) T_VALID : coverpoint TVALID;
      #|--CROSS_HDR_TAILS             5.86% (15/256)                 145 (axi4_stream_if.sv) CROSS_HDR_TAILS : cross HDR_FLAGS, TAIL_FLAGS;
      if($line =~ /^\Q|--\E(\S+)\s+(\S+)%\s+\((\d+)\/(\d+)\).*(coverpoint|cross).*/) {
         $cover_item_name = $1;
         print "\tTreeNode base_coverpoint_${cover_point_number};\n";
         $cover_point_number++;
         $cover_item_number++;
      };

      #Covervalues
      #Regexp example
      #| |--auto[0]                   100.00% (60085/1)              84 (axi4_stream_if.sv) T_VALID : coverpoint TVALID;
      if($line =~ /^\Q| |--\E(\S+)\s+(\S+)%\s+\((\d+)\/(\d+)\).*/) {
         $cover_item_name = $1;
         print "\tTreeNode base_covervalue_${cover_value_number};\n";
         $cover_value_number++;
         $cover_item_number++;
      };
   };
   if($line =~ /^$/ and $instance_begin) {
      $instance_end = 1;
      $instance_begin = 0;
   };
};

print "\n";
print "\tbase_covermodel = new();\n";
print "\tbase_covermodel.node_id = 1;\n";
print "\tbase_covermodel.name = \"root\";\n\n";

#Reset var values
$instance_found= 0;
$instance_begin= 0;
$instance_end= 0;

$cover_item_number=1;
$cover_item_functional_cov_overall_covered = 0;
$cover_item_functional_cov_points_covered = 0;
$cover_item_functional_cov_points_total = 0;

$cover_group_number=0;
$cover_point_number=0;
$cover_value_number=0;

#Then, define each TreeNode atributes
foreach my $line(@lines) {
   #Find start of instance
   if($line =~ /Instance\sname:\s(\S+)/) {
      $instance_name = $1;
   };
   if($instance_found) {
      $instance_found = 0;
      $instance_begin = 1;
      $instance_end = 0;
      #Division line
      next
   };
   if($line =~ /Name.*Covered/) {
      $instance_found = 1;
      $instance_begin = 0;
      $instance_end = 1;
   };
   if($instance_begin and !$instance_end) {

      #Covergroups
      #Regexp example
      #axi4                           47.73%, 9.88% (119/1205)       82 (axi4_stream_if.sv) covergroup axi4_cg @ (posedge ACLK);
      if($line =~ /(\S+)\s+(\S+)%,\s+(\S+)%\s+\((\d+)\/(\d+)\).*covergroup/) {
         $cover_item_number++;
         $cover_item_name = $1;
         $cover_item_functional_cov_overall_covered = $3;
         $cover_item_functional_cov_points_covered = $4;
         $cover_item_functional_cov_points_total = $5;
         print "\tbase_covergroup_${cover_group_number} = new();\n";
         print "\tbase_covergroup_${cover_group_number}.node_id = $cover_item_number;\n";
         print "\tbase_covergroup_${cover_group_number}.name = \"$cover_item_name\";\n";
         print "\tbase_covergroup_${cover_group_number}.level = 1;\n";
         print "\tbase_covergroup_${cover_group_number}.set_cov_data($cover_item_functional_cov_overall_covered, $cover_item_functional_cov_points_covered, $cover_item_functional_cov_points_total);\n";
         print "\tbase_covergroup_${cover_group_number}.add_influence_param_data();\n";
         print "\tbase_covermodel.add_child(base_covergroup_${cover_group_number});\n\n";
         $cover_group_number++;
      };

      #Coverpoints
      #Regexp example
      #|--T_VALID                     100.00% (2/2)                  84 (axi4_stream_if.sv) T_VALID : coverpoint TVALID;
      #|--CROSS_HDR_TAILS             5.86% (15/256)                 145 (axi4_stream_if.sv) CROSS_HDR_TAILS : cross HDR_FLAGS, TAIL_FLAGS;
      if($line =~ /^\Q|--\E(\S+)\s+(\S+)%\s+\((\d+)\/(\d+)\).*(coverpoint|cross).*/) {
         $cover_item_number++;
         $cover_item_name = $1;
         $cover_item_functional_cov_overall_covered = $2;
         $cover_item_functional_cov_points_covered = $3;
         $cover_item_functional_cov_points_total = $4;
         print "\tbase_coverpoint_${cover_point_number} = new();\n";
         print "\tbase_coverpoint_${cover_point_number}.node_id = $cover_item_number;\n";
         print "\tbase_coverpoint_${cover_point_number}.name = \"$cover_item_name\";\n";
         print "\tbase_coverpoint_${cover_point_number}.level = 2;\n";
         print "\tbase_coverpoint_${cover_point_number}.set_cov_data($cover_item_functional_cov_overall_covered, $cover_item_functional_cov_points_covered, $cover_item_functional_cov_points_total);\n";
         print "\tbase_coverpoint_${cover_point_number}.add_influence_param_data();\n";
         $cover_group_number--;
         print "\tbase_covergroup_${cover_group_number}.add_child(base_coverpoint_${cover_point_number});\n\n";
         $cover_group_number++;
         $cover_point_number++;
      };

      #Covervalues
      #Regexp example
      #| |--auto[0]                   100.00% (60085/1)              84 (axi4_stream_if.sv) T_VALID : coverpoint TVALID;
      if($line =~ /^\Q| |--\E(\S+)\s+(\S+)%\s+\((\d+)\/(\d+)\).*/) {
         $cover_item_number++;
         $cover_item_name = $1;
         $cover_item_functional_cov_overall_covered = $2;
         $cover_item_functional_cov_points_covered = $3;
         $cover_item_functional_cov_points_total = $4;
         print "\tbase_covervalue_${cover_value_number} = new();\n";
         print "\tbase_covervalue_${cover_value_number}.node_id = $cover_item_number;\n";
         print "\tbase_covervalue_${cover_value_number}.name = \"$cover_item_name\";\n";
         print "\tbase_covervalue_${cover_value_number}.level = 3;\n";
         print "\tbase_covervalue_${cover_value_number}.set_cov_data($cover_item_functional_cov_overall_covered, $cover_item_functional_cov_points_covered, $cover_item_functional_cov_points_total);\n";
         print "\tbase_covervalue_${cover_value_number}.add_influence_param_data();\n";
         $cover_point_number--;
         print "\tbase_coverpoint_${cover_point_number}.add_child(base_covervalue_${cover_value_number});\n\n";
         $cover_point_number++;
         $cover_value_number++;
      };
   };
   if($line =~ /^$/ and $instance_begin) {
      $instance_end = 1;
      $instance_begin = 0;
   };
};

print"\tbase_covermodel.print_tree(1);\n\n";

print"\tbase_tree_weight = base_covermodel.get_tree_weight();\n";
print"\ts.itoa(base_tree_weight);\n";
print"\t\$display({\"SEED_SELECTOR: base tree weight : \", s});\n\n";
print"\tbase_covermodel.update_seed_tree_weight(influence_param_1);\n\n";
print"\tseed_tree_weight = base_covermodel.get_tree_weight();\n";
print"\ts.itoa(seed_tree_weight);\n";
print"\t\$display({\"SEED_SELECTOR: seed tree weight : \", s});\n\n";
print"\t\if (base_tree_weight > seed_tree_weight) begin\n";
print"\t\tseed_selector_result = 0;\n";
print"\t\t\$display(\"SEED_SELECTOR: APPROVED\");\n";
print"\tend\n";
print"\telse begin\n";
print"\t\tseed_selector_result = 7;\n";
print"\t\t\$display(\"SEED_SELECTOR: DISCARDED\");\n";
print"\tend\n";
print"\treturn seed_selector_result;\n";
print"endfunction";
exit 1;


#`include "../../run/seed_selector/cov_tree_defs_and_methods.sv"
#
#function void build_base_covmodel_tree();
#
#   TreeNode base_covermodel;
#	 TreeNode base_covergroup_0;
#	 TreeNode base_coverpoint_0;
#	 TreeNode base_covervalue_0;
#	 TreeNode base_covervalue_1;
#	 TreeNode base_coverpoint_1;
#	 TreeNode base_covervalue_2;
#	 TreeNode base_covervalue_3;
#
#   base_covermodel = new();
#   base_covermodel.node_id = 1;
#   base_covermodel.name = "root";
#
#   base_covergroup_0 = new();
#   base_covergroup_0.node_id = 2;
#   base_covergroup_0.name = "axi4";
#   base_covergroup_0.level = 1;
#	 base_covergroup_0.set_cov_data(38.88, 229, 589);
#	 base_covermodel.add_child(base_covergroup_0);
#	 base_covermodel.add_influence_param_data();
