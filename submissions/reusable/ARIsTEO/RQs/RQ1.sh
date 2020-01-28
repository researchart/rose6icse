#!/bin/bash  
source /etc/profile

models=(RHB1 RHB2 AT AFC IGC)
modelscript=(staliro_heat_bench_demo_01 staliro_heat_bench_demo_02 staliro_demo_autotrans_01 staliro_arch_competition_experiments staliro_insulin_glucose_ctrl)
modelstructures=(arx armax bj tf ss nlarx hw)

index=0;

for k in 1 2 3 4 5
do
for i in "${models[@]}"; 
do 		
	for j in "${modelstructures[@]}";
	do
		name="$i$j$k"
		sbatch -J "$name" -n 10 -N 4 --priority=TOP -t 4-00:00:00  ./launchRQ1.sh "$i" "$j" "${modelscript[$index]}" "$k";
	done
	index=$(($index+1))
done
done
exit
