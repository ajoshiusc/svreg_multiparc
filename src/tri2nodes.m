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


%
function T2N=tri2nodes(surf1)

%A=voronoi_area(surf1);
A=tri_area(surf1.faces,surf1.vertices);
%[cc,VC]=vertices_connectivity_fast(surf1);
C=face_v_conn(surf1);


T2N=spdiags(1./(C*A'),0,length(surf1.vertices),length(surf1.vertices))*(C*spdiags(A',0,length(A),length(A)));
