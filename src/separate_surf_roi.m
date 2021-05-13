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



function surf1=separate_surf_roi(surf1,rois)

vert=0*surf1.labels;

for jj=1:length(rois)
    vert = vert + (surf1.labels==rois(jj));
end

vert=(vert~=0);

usedf=vert(surf1.faces);
usedf=sum(usedf,2);usedf=(usedf==3);
surf1.faces(usedf==0,:)=[];
surf1=myclean_patch3(surf1);
surf1=myclean_patch_cc(surf1);
%surf1=myclean_patch_cc(surf1);



