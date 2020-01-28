% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
function expr = minus(expr1, expr2)
%MINUS Substraction operator for MPTAFFEXPR objects

% Copyright is with the following author(s):
%
%(C) 2005 Michal Kvasnica, Automatic Control Laboratory, ETH Zurich,
%         kvasnica@control.ee.ethz.ch

% ---------------------------------------------------------------------------
% Legal note:
%          This program is free software; you can redistribute it and/or
%          modify it under the terms of the GNU General Public
%          License as published by the Free Software Foundation; either
%          version 2.1 of the License, or (at your option) any later version.
%
%          This program is distributed in the hope that it will be useful,
%          but WITHOUT ANY WARRANTY; without even the implied warranty of
%          MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%          General Public License for more details.
% 
%          You should have received a copy of the GNU General Public
%          License along with this library; if not, write to the 
%          Free Software Foundation, Inc., 
%          59 Temple Place, Suite 330, 
%          Boston, MA  02111-1307  USA
%
% ---------------------------------------------------------------------------


if ~(isa(expr1, 'mptaffexpr') | isa(expr1, 'double') | isa(expr1, 'mptvar'))
    error(sprintf('Variables of class "%s" not supported!', class(expr1)));
end
if ~(isa(expr2, 'mptaffexpr') | isa(expr2, 'double') | isa(expr2, 'mptvar'))
    error(sprintf('Variables of class "%s" not supported!', class(expr2)));
end

expr2 = -expr2;

expr = plus(expr1, expr2);
