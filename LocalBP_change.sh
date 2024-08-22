local=(1024 2048)

BranchPredictorFile="/home/011/k/kx/kxr230001/CA_Project_1/gem5/src/cpu/pred/BranchPredictor.py"
start_class="LocalBP(BranchPredictor)"
end_class="TournamentBP(BranchPredictor)"
keyword1="localPredictorSize"
BENCHMARKno1=456.hmmer
BENCHMARKno2=458.sjeng
l1d="128kB"
l1i="128kB"
l2="1MB"
l1d_assoc=2
l1i_assoc=2
l2_assoc=4
cs=64


ca_base=$(echo ~)/CA_Project_1
echo $ca_base
data=$ca_base/data
echo $data
 cd /home/011/k/kx/kxr230001/CA_Project_1/gem5/src/ 

for l in "${local[@]}"
do
    filename="l_${l}"
  echo $filename
		# Get the line numbers of the start and end classes
		start=$(grep -n "^class $start_class" $BranchPredictorFile | cut -d: -f1)
		end=$(grep -n "^class $end_class" $BranchPredictorFile | cut -d: -f1)

		if [ -z "$start" ]; then
		  echo "Class $start not found in file $BranchPredictorFile."
		  exit 1
		fi

		if [ -z "$end" ]; then
		  echo "Class $end not found in file $BranchPredictorFile."
		  exit 1
		fi
		line_num1=$(awk 'NR>='$start' && NR<= '$end' && /'$keyword1'/{print NR}' $BranchPredictorFile)
		if [[ ! -z "$line_num1" ]]; then
			sed -i "${line_num1}s/[0-9][0-9][0-9][0-9]/${l}/g" "$BranchPredictorFile"
			echo "Line $line_num1 modified"
		fi
		
		echo -e "****** DELETING OLD BUILD FILE   ******\n"
		cd $ca_base/gem5
		rm -rf ./build/X86
		echo -e "****** COMPILING THE SOURCE CODE ******\n"
		scons build/X86/gem5.opt -j 4

		echo -e "****** MAKING CHANGE IN THE SOURCE CODE ******\n"
		for q in {1..2}; do
			 sed -i "s|time.*$|time \$GEM5_DIR/build/X86/gem5.opt -d ./${filename} \$GEM5_DIR/configs/example/se.py -c \$BENCHMARK -o \$ARGUMENT -I 5000000 --cpu-type=timing --caches --l2cache --l1d_size=${l1d} --l1i_size=${l1i} --l2_size=${l2} --l1d_assoc=${l1d_assoc} --l1i_assoc=${l1i_assoc} --l2_assoc=${l2_assoc} --cacheline_size=${cs}|g" $ca_base/Project1_SPEC-master/$(eval echo \${BENCHMARKno${q}})/runGem5.sh
		   done


		echo starting_sleep
		  for t in {1..2}; do
			cd $ca_base/Project1_SPEC-master/$(eval echo \${BENCHMARKno${t}}) && sh $ca_base/Project1_SPEC-master/$(eval echo \${BENCHMARKno${t}})/runGem5.sh &
		  done
		wait

	cd $ca_base
	  done
	
