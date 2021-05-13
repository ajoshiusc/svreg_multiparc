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



function [p,loc]=myclean_patch3(p)
%p.vertices=1e-15*round(p.vertices*1e15);
po=p;

p.faces=myclean_tri(p.faces);
X=p.vertices(:,1);Y=p.vertices(:,2);Z=p.vertices(:,3);
Xf=X(p.faces);Yf=Y(p.faces);Zf=Z(p.faces);
d1=(abs(Xf(:,1)-Xf(:,2))>eps)+(abs(Yf(:,1)-Yf(:,2))>eps)+(abs(Zf(:,1)-Zf(:,2))>eps);
d2=(abs(Xf(:,1)-Xf(:,3))>eps)+(abs(Yf(:,1)-Yf(:,3))>eps)+(abs(Zf(:,1)-Zf(:,3))>eps);
d3=(abs(Xf(:,3)-Xf(:,2))>eps)+(abs(Yf(:,3)-Yf(:,2))>eps)+(abs(Zf(:,3)-Zf(:,2))>eps);
d=d1.*d2.*d3;
gT=find(d>0);
%disp(sprintf('%d bad triangles (with 2 or more identical vertices)!!',size(p.faces,1)-size(gT,1)));
p.faces=p.faces(gT,:);
p=delete_unused_vertices(p);

[~,ind,ind2]=unique(1e-15*round(p.vertices*1e15),'rows');
p.vertices=p.vertices(ind,:);
p.faces=ind2(p.faces);

%[p.vertices,ia,ib] = unique(p.vertices,'rows');
%p.faces=ib(p.faces);%deletes points that are repeated

[c,loc]=ismember(p.vertices,po.vertices,'rows');
if sum(c)==length(p.vertices)
   if isfield(po,'vcolor')
       p.vcolor=po.vcolor(loc,:);
   end
   if isfield(po,'attributes')
       p.attributes=po.attributes(loc);
   end
   if isfield(po,'labels')
       p.labels=po.labels(loc);
   end
   
   if isfield(po,'u')
       p.u=po.u(loc);       p.v=po.v(loc);
   end
   
end
    


