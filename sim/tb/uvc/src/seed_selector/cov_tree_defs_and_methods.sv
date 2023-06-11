class TreeNode;
   //properties
   int node_id;
   string name;
   TreeNode children [$];
   TreeNode parent;
   int level;
   real functional_cov_overall_covered;
   int functional_cov_points_covered;
   int functional_cov_points_total;
   int weight;

   //constructor method
   function new();
      node_id = 1;
      name = "root";
      level = 0;
      functional_cov_overall_covered = 0.0;
      functional_cov_points_covered = 0;
      functional_cov_points_total = 0;
      weight = 0;
   endfunction

   function void print_tree(int details = 0);
      string spaces = {this.level{"   "}};
      string prefix, prefix2, s = "";
      if (this.node_id != 1 ) begin
        prefix = {spaces, "|__"};
        prefix2 = {spaces, "***"};
      end
      $display({prefix, this.name});
      if ((this.node_id != 1) && (details == 1)) begin
         s.realtoa(this.functional_cov_overall_covered);
         $display({prefix2, "functional_cov_overall_covered: ", s, "%"});
         s.itoa(this.functional_cov_points_covered);
         $display({prefix2, "functional_cov_points_covered : ", s});
         s.itoa(this.functional_cov_points_total);
         $display({prefix2, "functional_cov_points_total   : ", s});
         s.itoa(this.weight);
         $display({prefix2, "weight                        : ", s});
      end
      if (this.children.size() !=0 ) begin
         for (int i = 0; i < $size(this.children); i++) begin
              this.children[i].print_tree(details);
         end
      end
   endfunction

   function void add_child(TreeNode child);
       this.children.push_back(child);
   endfunction

   function void add_cov_data(real ovr_covered, int cov_points_covered, int cov_points_total);
       this.functional_cov_overall_covered = ovr_covered;
       this.functional_cov_points_covered = cov_points_covered;
       this.functional_cov_points_total = cov_points_total;
       this.weight = (cov_points_total>cov_points_covered) ? (cov_points_total-cov_points_covered) : 0;
   endfunction

endclass
