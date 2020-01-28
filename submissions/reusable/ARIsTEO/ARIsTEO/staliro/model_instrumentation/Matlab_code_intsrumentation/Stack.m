% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
%   Copyright (c) 2014, Brian Moore
%   All rights reserved.
% 
%   Redistribution and use in source and binary forms, with or without
%   modification, are permitted provided that the following conditions are
%    met:
% 
%         * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%         * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
%   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%   POSSIBILITY OF SUCH DAMAGE.
% 
classdef Stack < handle
%--------------------------------------------------------------------------
% Class:        Stack < handle
%               
% Constructor:  S = Stack(n);
%               S = Stack(n,x0);
%               
% Properties:   (none)
%               
% Methods:                 S.Push(xi);
%               xi       = S.Pop();
%               count    = S.Count();
%               capacity = S.Capacity();
%               bool     = S.IsEmpty();
%               bool     = S.IsFull();
%                          S.Clear();
%               
% Description:  This class implements a first-in last-out (FILO) stack of
%               numeric values
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         January 16, 2014
%--------------------------------------------------------------------------

    %
    % Private properties
    %
    properties (Access = private)
        k;                  % current number of elements
        n;                  % stack capacity
        x;                  % stack array
    end
    
    %
    % Public methods
    %
    methods (Access = public)
        %
        % Constructor
        %
        function this = Stack(n,x0)
            %----------------------- Constructor --------------------------
            % Syntax:       S = Stack(n);
            %               S = Stack(n,x0);
            %               
            % Inputs:       n is the maximum number of values that S can
            %               hold
            %               
            %               x0 is a vector (of length <= n) of numbers to
            %               add to the stack during initialization
            %               
            % Description:  Creates a FILO stack with capacity n
            %--------------------------------------------------------------
            
            % Initialize stack
            if (n == 0)
                Stack.ZeroCapacityError();
            end
            this.n = n;
            this.x = nan(n,1);
            
            if ((nargin == 2) && ~isempty(x0))
                % Insert given elements
                k0 = numel(x0);
                if (k0 > n)
                    % Stack overflow
                    Stack.OverflowError();
                else
                    this.x(1:k0) = x0(:);
                    this.SetLength(k0);
                end
            else
                % Empty stack
                this.Clear();
            end
        end
        
        %
        % Push element onto stack
        %
        function Push(this,xi)
            %--------------------------- Push -----------------------------
            % Syntax:       S.Push(xi);
            %               
            % Inputs:       xi is a numeric value
            %               
            % Description:  Adds value xi to S
            %--------------------------------------------------------------
            
            this.SetLength(this.k + 1);
            this.x(this.k) = xi;
        end
        
        %
        % Pop element from stack
        %
        function xi = Pop(this)
            %--------------------------- Pop ------------------------------
            % Syntax:       xi = S.Pop();
            %               
            % Inputs:       xi is a numeric value
            %               
            % Description:  Removes top value from S
            %--------------------------------------------------------------
            
            this.SetLength(this.k - 1);
            xi = this.x(this.k + 1);
        end
        
        %
        % Return number of elements in stack
        %
        function count = Count(this)
            %-------------------------- Count -----------------------------
            % Syntax:       count = S.Count();
            %               
            % Outputs:      count is the number of values in S
            %               
            % Description:  Returns the number of values in S
            %--------------------------------------------------------------
            
            count = this.k;
        end
        
        %
        % Return stack capacity
        %
        function capacity = Capacity(this)
            %------------------------- Capacity ---------------------------
            % Syntax:       capacity = S.Capacity();
            %               
            % Outputs:      capacity is the size of S
            %               
            % Description:  Returns the maximum number of values that can 
            %               fit in S
            %--------------------------------------------------------------
            
            capacity = this.n;
        end
        
        %
        % Check for empty stack
        %
        function bool = IsEmpty(this)
            %------------------------- IsEmpty ----------------------------
            % Syntax:       bool = S.IsEmpty();
            %               
            % Outputs:      bool = {true,false}
            %               
            % Description:  Determines if S is empty (i.e., contains zero
            %               values)
            %--------------------------------------------------------------
            
            if (this.k == 0)
                bool = true;
            else
                bool = false;
            end
        end
        
        %
        % Check for full stack
        %
        function bool = IsFull(this)
            %-------------------------- IsFull ----------------------------
            % Syntax:       bool = S.IsFull();
            %               
            % Outputs:      bool = {true,false}
            %               
            % Description:  Determines if S is full
            %--------------------------------------------------------------
            
            if (this.k == this.n)
                bool = true;
            else
                bool = false;
            end
        end
        
        %
        % Clear the stack
        %
        function Clear(this)
            %-------------------------- Clear -----------------------------
            % Syntax:       S.Clear();
            %               
            % Description:  Removes all values from S
            %--------------------------------------------------------------
            
            this.SetLength(0);
        end
    end
    
    %
    % Private methods
    %
    methods (Access = private)
        %
        % Set length
        %
        function SetLength(this,k)
            if (k < 0)
                Stack.UnderflowError();
            elseif (k > this.n)
                Stack.OverflowError();
            end
            this.k = k;
        end
    end
    
    %
    % Private static methods
    %
    methods (Access = private, Static = true)
        %
        % Overflow error
        %
        function OverflowError()
            error('Stack overflow');
        end
        
        %
        % Underflow error
        %
        function UnderflowError()
            error('Stack underflow');
        end
        
        %
        % No capacity error
        %
        function ZeroCapacityError()
            error('Stack with no capacity is not allowed');
        end
    end
end
