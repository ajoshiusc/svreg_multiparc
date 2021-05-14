% SVReg: Surface-Constrained Volumetric Registration
% Copyright (C) 2019 The Regents of the University of California and the University of Southern California
% Created by Anand A. Joshi, Chitresh Bhushan, David W. Shattuck, Richard M. Leahy 
% 
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; version 2.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
% USA.


function h=mysphere(vC,k,clo,numpts)
%vC=[XV,YV,ZV], k=radius clo= color string
if ~exist('numpts','var');
    numpts=10;
end
[iR iC] = size(vC);
for iCount = 1: 1 : iR
    [a b c] = sphere(numpts);
    hold on
   h= surf(k*a+vC(iCount,1),k*b+vC(iCount,2),k*c+vC(iCount,3),eps*ones(size(c)),'EdgeColor','none','FaceColor',clo);
end
 
