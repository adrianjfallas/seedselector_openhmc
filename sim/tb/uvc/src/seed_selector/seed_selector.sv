seed_selector_result = build_base_covmodel_tree(max_flit_delay);

if (seed_selector_result == 7) begin
   `uvm_fatal(get_type_name(), "SEED_SELECTOR: DISCARDED")
end
