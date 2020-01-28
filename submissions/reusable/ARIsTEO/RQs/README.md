To replicate RQ1.
Open the main folder of ARIsTEO

Execute one of the following commands depending on the model you want to consider 
staliro_heat_bench_demo_01;             % For RHB1
staliro_heat_bench_demo_02;             % For RHB2
staliro_demo_autotrans_01;              % For AT
staliro_arch_competition_experiments;   % For AFC
staliro_insulin_glucose_ctrl;           % For IGC

Run 

``RQ1(model,structure,order);``

where 
    model is one among 'RHB1' 'RHB2' 'AT' 'AFC' 'IGC' and
    structure is one among 'arx' 'armax' 'bj' 'tf' 'ss' 'nlarx' 'hw'
    order is '1' or '2' or the selected order


To replicate RQ2.
Open the main folder of ARIsTEO

Execute
RQ2andRQ3('aristeo',num) and

RQ2andRQ3('staliro',mum)

where num is the maximum number of executions of the MUT

For example, RQ2andRQ3('aristeo',7) replicates the experiments of ARIsTEO when 7 iterations are considered.


To replicate all the RQ1 experiments execute RQ1.sh<br/>
To replicate all the RQ2 and RQ3 execute RQ2andRQ3.sh<br/>

Note that the sh scripts are defined to execute RQ1.m and RQ2andRQ3.m on our cluster. <br/>
If you want to use another cluster (or your laptop) the files with extension .sh should be modified.<br/>

If you want to run the experiments on your laptop you can run RQ1.m and RQ2andRQ3.m<br/>

type ``help RQ1.m`` or ``help RQ2andRQ3.m`` for information related with the parameters of the script




