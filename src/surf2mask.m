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


function msk=surf2mask(surf1,vv,msk_width,flag)
if ~exist('flag','var')
    flag=0;
end
surf1=refine_surf(surf1);surf1=refine_surf(surf1);surf1=refine_surf(surf1);surf1=refine_surf(surf1);
res=vv.hdr.dime.pixdim(2:4);

ind=sub2ind(size(vv.img),round(surf1.vertices(:,1)/res(1)+1),round(surf1.vertices(:,2)/res(2)+1),round(surf1.vertices(:,3)/res(3)+1));
vv.img=0*vv.img;
vv.img(ind)=1;
if flag == 0
    vv.img=imdilate(vv.img,ones(3+msk_width,3+msk_width,3+msk_width));
    vv.img=imerode(vv.img,ones(3,3,3));
end
msk=imfill(vv.img,'holes');
%msk=vv.img;
if flag == -1
    msk(ind)=0;
end
