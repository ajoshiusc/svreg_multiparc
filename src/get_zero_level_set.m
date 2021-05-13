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


function [pts,tri]=get_zero_level_set(surf1,phi)
%pts=get_zero_level_set(surf1,phi)
%find triangles for which phi crosses zero

tphi=phi(surf1.faces); tphi=sort(tphi,2); 
bdrtri=(tphi(:,1)<0 & tphi(:,3)>=0);

tri=surf1.faces(bdrtri,:); 

edges=[tri(:,1),tri(:,2);tri(:,1),tri(:,3);tri(:,2),tri(:,3);];

edges=sort(edges,2);edges=unique(edges,'rows');

edges(phi(edges(:,1)).*phi(edges(:,2)) > 0,:)=[]; %delete the edges for which phi has same sign;
a=phi(edges(:,1));b=phi(edges(:,2));
a(a==0)=eps;b(b==0)=eps;
w1=-a./(b); w2=-b./(a);wt1=w1./(w1+w2);wt2=w2./(w1+w2);

pts=repmat(wt2,1,3).*surf1.vertices(edges(:,1),:) + repmat(wt1,1,3).*surf1.vertices(edges(:,2),:);



