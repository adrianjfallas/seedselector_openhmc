#!/bin/bash

function print_help {
	printf "Usage: %s:
           [-e]                                      : Activates seed selector.
           [-p] <TARGET_FUNCTIONAL_COVERAGE_PERCENT> : Stops regression when a certain functional coverage percent is reached.
           [-?]                                      : Prints this help.\n" $(basename $0) >&2
}

#-----------------------------------------------------------------
# set defaults
target_functional_coverage_percent=90
seed_selector=0

#-- parse options
while getopts ':p:e?:' OPTION
do
	case $OPTION in
		e)	seed_selector=1
			;;
		p)	target_functional_coverage_percent="${OPTARG}"
			;;
		?)	print_help
			exit 2
			;;
		esac
done
shift $(($OPTIND - 1))

main () {
   time {
      if [ ! $OPENHMC_SIM ]
      then
          echo "Please export OPENHMC_SIM first"
          exit 1
      fi

      if [ ! $OPENHMC_PATH ]
      then
          echo "Please export OPENHMC_PATH first"
          exit 1
      fi

      export CAG_TB_DIR=${OPENHMC_SIM}/tb/uvc
      export CAG_DUT="openhmc_behavioral_uvc"

      #-----------------------------------------------------------------

      echo ""
      echo "*"
      echo "*                              .--------------. .----------------. .------------. "
      echo "*                             | .------------. | .--------------. | .----------. |"
      echo "*                             | | ____  ____ | | | ____    ____ | | |   ______ | |"
      echo "*                             | ||_   ||   _|| | ||_   \  /   _|| | | .' ___  || |"
      echo "*       ___  _ __   ___ _ __  | |  | |__| |  | | |  |   \/   |  | | |/ .'   \_|| |"
      echo "*      / _ \| '_ \ / _ \ '_ \ | |  |  __  |  | | |  | |\  /| |  | | || |       | |"
      echo "*       (_) | |_) |  __/ | | || | _| |  | |_ | | | _| |_\/_| |_ | | |\ '.___.'\| |"
      echo "*      \___/| .__/ \___|_| |_|| ||____||____|| | ||_____||_____|| | | '._____.'| |"
      echo "*           | |               | |            | | |              | | |          | |"
      echo "*           |_|               |  ------------  | '--------------' | '----------' |"
      echo "*                              '--------------' '----------------' '------------' "
      echo "*"
      echo "*"
      echo "*                 *******************************************************"
      echo "*                 *                                                     *"
      echo "*                 *      openHMC Verification Environment               *"
      echo "*                 *                                                     *"
      echo "*                 *      using CAG HMC Verification Model               *"
      echo "*                 *                                                     *"
      echo "*                 *******************************************************"
      echo ""



      echo -e "\n********************************************************************************* "
      echo -e "*** Running regression"
      echo -e "*** Name:   $regression_name"
      echo -e "*** Folder: $regressions_folder"
      echo -e "*********************************************************************************\n "

      #List of tests
      tests_list=(
                  #"atomic_pkt_test"
                  #"big_pkt_test"
                  #"big_pkt_hdelay_test"
                  #"big_pkt_zdelay_test"
                  #"posted_pkt_test"
                  #"non_posted_pkt_test"
                  #"init_test"
                  #"high_delay_pkt_test"
                  "simple_test"
                  #"single_pkt_test"
                  #"sleep_mode_test"
                  #"small_pkt_hdelay_test"
                  #"small_pkt_test"
                  #"small_pkt_zdelay_test"
                  #"zero_delay_pkt_test"
                  #"error_pkt_test"
                  #"bit_error_test"
                  )
      num_tests=${#tests_list[*]}
      test_runs=0

      if [ "$seed_selector" -ne 0 ]
      then
         echo "Creating seed_selector folder"
         mkdir $regression_path/seed_selector/
         cp -v ${OPENHMC_SIM}/tb/uvc/src/seed_selector/seed_selector.sv $regression_path/seed_selector/
         cp -v ${OPENHMC_SIM}/tb/uvc/src/seed_selector/cov_tree_defs_and_methods.sv $regression_path/seed_selector/
         echo -e "\`include \"seed_selector/cov_tree_defs_and_methods.sv\"\n\nfunction int build_base_covmodel_tree(int influence_param_1);\n\n\t\$display(\"SEED_SELECTOR: First test run, no coverage tree yet.\");\n\nendfunction" > ${OPENHMC_SIM}/tb/uvc/src/seed_selector/tree_cov_model_base.sv
         cp -v ${OPENHMC_SIM}/tb/uvc/src/seed_selector/tree_cov_model_base.sv $regression_path/seed_selector/
         echo -e "\n"
      fi

      #until [[ $(($total_functional_coverage_percent)) -ge $(($target_functional_coverage_percent)) ]] || [[ "$test_runs" -ge 4 ]]
      until [[ $(($total_functional_coverage_percent)) -ge $(($target_functional_coverage_percent)) ]]
      do
         test_idx=$(($RANDOM % $num_tests))
         current_test=${tests_list[$test_idx]}
         echo "$current_test"
         current_test_run="$current_test"__`date +"%Y_%m_%d__%H_%M_%S"`
         current_test_run_path="$regression_path"/"$current_test_run"
         echo -e "Running test: $current_test_run"
         mkdir $current_test_run_path
         cd $current_test_run_path
         random_seed=$RANDOM

         if [ "$seed_selector" -ne 0 ]
         then
            #TODO Find out how to pass the tree file
            ${OPENHMC_SIM}/tb/run/run_files/run.sh -t $current_test -o -c -e -s $random_seed $*
            if [ "$test_runs" -gt 0 ]
            then
               ${OPENHMC_SIM}/tb/run/seed_selector_parsing.pl
               ## If seed selector discards
               if [ "$?" -eq 7 ]
               then
                   cd $regression_path
                   echo -e "Removing $current_test_run since it was discarded by the seed selector...\n\n"
                   rm -rf $current_test_run_path
                   echo -e "$current_test_run random_seed: $random_seed current_collected_functional_coverage_percent: $total_functional_coverage_percent% [DISCARDED BY SEED_SELECTOR]" >> seeds.log
                   ((test_runs+=1))
                   continue
               fi
            fi
         else
            ${OPENHMC_SIM}/tb/run/run_files/run.sh -t $current_test -o -c -s $random_seed $*
         fi
         ((test_runs+=1))

         cd $regression_path
         rm -rf automerge/ automerge.cmd autorunfile
         ${OPENHMC_SIM}/tb/run/merge_cov
         imc -load ./automerge -execcmd "report -detail -inst tb_top.axi4_hmc_req_if -metrics covergroup -both" > merged_functional_coverage_axi4_hmc_req_if.log
         #imc -load ./automerge -execcmd "report -summary -metrics covergroup -cumulative on -local off" > merged_functional_coverage_summary.log
         ##imc -load ./automerge -execcmd "report -summary -metrics functional -cumulative on -local off" > merged_functional_coverage_summary.log
         ${OPENHMC_SIM}/tb/run/cov_report_parsing.pl
         total_functional_coverage_percent=$?
         echo -e "$current_test_run random_seed: $random_seed current_collected_functional_coverage_percent: $total_functional_coverage_percent%" >> seeds.log
         echo -e "current_collected_functional_coverage_percent: $total_functional_coverage_percent%"
         echo -e "target_functional_coverage_percent           : $target_functional_coverage_percent%\n"
         if [ "$seed_selector" -ne 0 ]
         then
            #Updating tree coverage model
            echo -e "Creating base tree coverage model"
            imc -load ./automerge -execcmd "report -detail -inst tb_top.* -metrics covergroup -both" > $regression_path/seed_selector/merged_functional_coverage_detailed.log
            cd $regression_path/seed_selector/
            ${OPENHMC_SIM}/tb/run/create_tree_cov_model.pl > $regression_path/seed_selector/tree_cov_model_base.sv
            cp -v $regression_path/seed_selector/tree_cov_model_base.sv $current_test_run_path
            cp -v $regression_path/seed_selector/tree_cov_model_base.sv ${OPENHMC_SIM}/tb/uvc/src/seed_selector/
            echo -e "Base tree coverage model created\n"
            cd $regression_path
         fi
      done
      if [ "$seed_selector" -ne 0 ]
      then
         #echo -e "Removing the repo's tree_cov_model_base.v file"
         #rm -rf ${OPENHMC_SIM}/tb/uvc/src/seed_selector/tree_cov_model_base.sv
         echo -e "Restoring the repo's tree_cov_model_base.v file"
         echo -e "\`include \"seed_selector/cov_tree_defs_and_methods.sv\"\n\nfunction int build_base_covmodel_tree(int influence_param_1);\n\n\t\$display(\"SEED_SELECTOR: First test run, no coverage tree yet.\");\n\nendfunction" > ${OPENHMC_SIM}/tb/uvc/src/seed_selector/tree_cov_model_base.sv
      fi
      echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
      echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
      echo -e " ╔╦╗╔═╗╔╦╗╔═╗╦    ╦═╗╔═╗╔═╗╦═╗╔═╗╔═╗╔═╗╦╔═╗╔╗╔  ╔╦╗╦╔╦╗╔═╗"
      echo -e "  ║ ║ ║ ║ ╠═╣║    ╠╦╝║╣ ║ ╦╠╦╝║╣ ╚═╗╚═╗║║ ║║║║   ║ ║║║║║╣ "
      echo -e "  ╩ ╚═╝ ╩ ╩ ╩╩═╝  ╩╚═╚═╝╚═╝╩╚═╚═╝╚═╝╚═╝╩╚═╝╝╚╝   ╩ ╩╩ ╩╚═╝"
      echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~";
   }
}

#-----------------------------------------------------------------
#-----------------------------------------------------------------
#Set these variables first
regressions_folder="/nis/asic/cr_dump2/fallasad/SeedSelector_OpenHMC/RegressionResults"
project="OpenHMC"
#-----------------------------------------------------------------
#-----------------------------------------------------------------

mkdir -p $regressions_folder

regression_name="$project"__`date +"%Y_%m_%d__%H_%M_%S"`
regression_path="$regressions_folder"/"$regression_name"
mkdir $regression_path
main 2>&1 | tee -a $regression_path/regression.log
