% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function [model_instr_info] = model_instrumentation(modelName,modelInitFile,projection_mode,exclusion_list)%,filename_string)%instrument_mode)
% Instruments the simulink model with output ports and returns an output struct with model information.
% Inputs:
%	modelName -  simulink model name to be instrumented
%   modelInitFile - .mat file required to compile the model. If no file is
%   required to compile mode, then empty string should be passed
%	exclusion_list - cell array of list of blocks that are to be excluded 
%   for instrumentation. The cell array must contain the complete path of 
%   the block in the model. 
%   For Ex: exclusion_list{1}=Toy_demo/subsystem1/switch1 will exclude the
%   block switch1 from instrumentation.
%   To obtain a complete list of switch and saturate blocks run the
%   Model_Reader function independently first before executing the 
%   model_instrumentation. Refer Model_Reader for further details.
% 
% Outputs:
%   model_instr_info -  structure with follpwing fields:
%       BBox_file_name - name of blackbox file generated.
%       New_Modelname - name of new model created after instrumentation
%       num_of_HAS - number of hybrid automatas. 
%       For ex: if there are 4 switch & 1 saturate block,then num_of_HAS=5 
%       HAs_state_matrix = row matrix with number of states in each hybrid
%       automata. For above ex: HAs_state_matrix=[2 2 2 2 3 ]

% check for input correctness
    if (nargin == 0 || nargin > 4 )
              fprintf('\n USAGE: BlackBoxToyotaEngine_added_features(''modelName'',)\n');
              fprintf('Please give model name without file extension.\n');
            return;
    elseif (nargin >0)
        % Check if modelName is not empty string
        if (isempty(modelName))
            fprintf('\n ERROR: Please pass Simulink model name as a parameter without file extension.\n');
            return;
        end
        if (nargin == 1)
            projection_mode = 0;
            exclusion_list={};
        
        elseif (nargin == 2)
            if (~isnumeric(projection_mode) || (projection_mode>1))
                error('\n projection_mode must be either 0 or 1 \n')
            end
            exclusion_list={};
        elseif (nargin == 3)
            if (~iscell(exclusion_list))
                error('\n the exclusion list must be a cell array of switch/saturate blocks \n')
            end
        end              
    end

    %Initialise the output structure
    model_instr_info=struct('BBox_file_name','','New_Modelname','','num_of_HAS',[],'HAs_state_matrix',[],'extra_outports_added',[],'num_org_outports',[]);
    
    info = s2mc(modelName,modelInitFile);
    [blocklist_struct, info]= Model_Reader(modelName,exclusion_list,info); % basic model annotation and blocklist generation
    % check for case where there are no switch and saturate blocks
    if isempty(blocklist_struct.saturate_blocks) && isempty(blocklist_struct.switch_blocks)
        fprintf('\n there are no switch and saturate block to instrument \n');
        return;
    end

    saturate_block_info = Saturation_Instrument(modelName,blocklist_struct.saturate_blocks,blocklist_struct.blockList); %Instruments Saturate blocks in the model and stores relevent info

    switch_block_info = Switch_Instrument(modelName,blocklist_struct.switch_blocks,...
    blocklist_struct.blockList,blocklist_struct.connHandleList,info,blocklist_struct.num_org_outports); % Instruments switch blocks in the model and stores relevent info

    New_Modelname = save_model_info(modelName);

    [CLG,new_guardsize] = Control_Graph(switch_block_info,saturate_block_info,projection_mode); % generate the control graph structure

    model_instr_info.BBox_file_name = Blackbox_generator(switch_block_info,saturate_block_info,CLG,modelName,New_Modelname,projection_mode); % write the blackbox file

    % update the output structure.
    num_org_outports = blocklist_struct.num_org_outports;
    extra_outports_added = new_guardsize - num_org_outports;
    num_of_sw=switch_block_info.num_of_boolsw+switch_block_info.num_of_doublesw;
    num_of_sat=saturate_block_info.num_of_satblocks;
    model_instr_info.num_of_HAS=num_of_sw+num_of_sat;
    HAs_state_matrix=zeros(1,model_instr_info.num_of_HAS);
    HAs_state_matrix(1,1:num_of_sw)=2;
    HAs_state_matrix(1,num_of_sw+1:num_of_sw+num_of_sat)=3;
    model_instr_info.HAs_state_matrix=HAs_state_matrix;
    model_instr_info.New_Modelname = New_Modelname;
    model_instr_info.extra_outports_added = extra_outports_added;
    model_instr_info.num_org_outports = num_org_outports;
    close_system(New_Modelname);
    fprintf('\n Blackbox for the model created succesfully \n');

end


