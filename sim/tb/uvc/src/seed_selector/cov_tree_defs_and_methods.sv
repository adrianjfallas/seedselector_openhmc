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
   string influence_param;
   int influence_param_range_min;
   int influence_param_range_max;

   //constructor method
   function new();
      node_id = 1;
      name = "root";
      level = 0;
      functional_cov_overall_covered = 0.0;
      functional_cov_points_covered = 0;
      functional_cov_points_total = 0;
      weight = 1;
      influence_param = "";
      influence_param_range_min = 0;
      influence_param_range_max = 0;
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
         $display({prefix2, "influence_param               : ", this.influence_param});
         s.itoa(this.influence_param_range_min);
         $display({prefix2, "influence_param_range_min     : ", s});
         s.itoa(this.influence_param_range_max);
         $display({prefix2, "influence_param_range_max     : ", s});
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

   function void update_seed_tree_weight(int influence_param_val);
      if ((this.level == 3 ) && (influence_param_val >= this.influence_param_range_min) && (influence_param_val <= this.influence_param_range_max) ) begin
         this.weight = 0;
      end
      if (this.children.size() !=0 ) begin
         for (int i = 0; i < $size(this.children); i++) begin
              this.children[i].update_seed_tree_weight(influence_param_val);
         end
      end
   endfunction

   function int get_tree_weight();
      int weight = 0;
      weight = weight + this.weight;
      if (this.children.size() !=0 ) begin
         for (int i = 0; i < $size(this.children); i++) begin
              weight = weight + this.children[i].get_tree_weight();
         end
      end
      return weight;
   endfunction

   function void set_cov_data(real ovr_covered, int cov_points_covered, int cov_points_total);
       this.functional_cov_overall_covered = ovr_covered;
       this.functional_cov_points_covered = cov_points_covered;
       this.functional_cov_points_total = cov_points_total;
       this.weight = (cov_points_total>cov_points_covered) ? (cov_points_total-cov_points_covered) : 0;
   endfunction

   function void set_influence_param_data(string influence_parameter, int influence_parameter_range_min, int influence_parameter_range_max);
       this.influence_param = influence_parameter;
       this.influence_param_range_min = influence_parameter_range_min;
       this.influence_param_range_max = influence_parameter_range_max;
   endfunction

   function void add_influence_param_data();
       if ((this.node_id >= 112 ) && (this.node_id <= 122)) begin
          case (node_id)
             112 :  begin
                     this.set_influence_param_data("flit_delay", 1, 8);
                  end
             113 :  begin
                     this.set_influence_param_data("flit_delay", 1, 8);
                  end
             114 :  begin
                     this.set_influence_param_data("flit_delay", 5, 12);
                  end
             115 :  begin
                     this.set_influence_param_data("flit_delay", 5, 12);
                  end
             116 :  begin
                     this.set_influence_param_data("flit_delay", 9, 16);
                  end
             117 :  begin
                     this.set_influence_param_data("flit_delay", 9, 16);
                  end
             118 :  begin
                     this.set_influence_param_data("flit_delay", 13, 20);
                  end
             119 :  begin
                     this.set_influence_param_data("flit_delay", 13, 19);
                  end
             120 :  begin
                     this.set_influence_param_data("flit_delay", 17, 24);
                  end
             121 :  begin
                     this.set_influence_param_data("flit_delay", 17, 22);
                  end
             122 : begin
                     this.set_influence_param_data("flit_delay", 21, 25);
                  end
             default : begin
                     this.set_influence_param_data("flit_delay", 0, 0);
                  end
          endcase
       end

   endfunction

endclass
