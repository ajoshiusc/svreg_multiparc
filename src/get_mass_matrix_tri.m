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



function M=get_mass_matrix_tri(surf1)

A=tri_area(surf1.faces,surf1.vertices);%A=ones(size(A));

V1=surf1.faces(:,1);V2=surf1.faces(:,2);V3=surf1.faces(:,3);

rows=[V1;V1;V1;V2;V2;V2;V3;V3;V3];

cols=[V1;V2;V3;V1;V2;V3;V1;V2;V3];

vals=[A./6;A./12;A./12;A./12;A./6;A./12;A./12;A./12;A./6];


M=sparse(rows,cols,vals);

