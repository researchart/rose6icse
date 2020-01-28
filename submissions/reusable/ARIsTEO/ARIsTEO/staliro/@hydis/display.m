% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
% Display function for hydis class

% (C) 2011 by Georgios Fainekos (fainekos@asu.edu)
% Last update: 2011.06.04

function display(inp)

sz_inp = size(inp.ds);

if isempty(inp.ds)
    disp(' ')
    display(['hydis ',inputname(1),' = ']);
    disp(' ')
    disp('      []');
    disp(' ')
elseif length(inp.ds)==1
    disp(' ')
    disp(['hydis ',inputname(1) ' =']);
    disp(' ')
    disp([' <',num2str(inp.dl),',',num2str(inp.ds),'>']);
    disp(' ')
elseif length(sz_inp)==2
    if sz_inp(2)==1
        disp(' ')
        disp(['hydis ',inputname(1) ' =']);
        disp(' ')
        for ii=1:sz_inp(1)
            disp([' <',num2str(inp.dl(ii,1)),',',num2str(inp.ds(ii,1)),'>']);
        end
        disp(' ')
    else
        disp(' ')
        disp(['hydis ',inputname(1) ' =']);
        disp(' ')
        out = cell(sz_inp);
        for ii=1:sz_inp(1)
            for jj=1:sz_inp(2)
                out{ii,jj} = sprintf(' <%d,%g>',inp.dl(ii,jj),inp.ds(ii,jj));
            end
        end
        disp(out)
        disp(' ')
    end
else
    display('hydis: Currently display is not supported for this size of a hydis object')
end
