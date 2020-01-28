% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
classdef DiscreteReachProjAdvTestCase < ...
        elltool.reach.test.mlunit.AReachProjAdvTestCase
    methods
        function self = DiscreteReachProjAdvTestCase(varargin)
            self = self@elltool.reach.test.mlunit.AReachProjAdvTestCase(...
                elltool.linsys.LinSysDiscreteFactory(), ...
                elltool.reach.ReachDiscreteFactory(), ...
                varargin{:});
        end
    end
end