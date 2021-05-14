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



function surf1=corr_topology_labels(surfname,sub_out)
if ~exist('sub_out','var')
    sub_out=surfname;
end
p=readdfs(surfname);

labs=unique(p.labels);%labs=setdiff(labs,[0]');
[vconn,A_full]=vertices_connectivity_fast(p);

for l=labs'
ind=find(p.labels==l);
A=A_full(ind,ind);
[s,c]=scomponents(A);
len=0;lcc=0;
for jj=1:s
    v=find(c==jj);v=length(v);
    
    if v>len
    lcc=jj;len=v;
    end
    
end


%    if (length(conn{jj})<2)
%        bad_tri=union(bad_tri,jj);
%    end
%end
p.labels(ind(c~=lcc))=-1;

end

%figure;
%patch('faces',p.faces,'vertices',p.vertices,'facevertexcdata',p.labels,'facecolor','flat','edgecolor','none')


for l=labs'
ind=find(p.labels==l | p.labels==-1);
A=A_full(ind,ind);
[s,c]=scomponents(A);
len=0;lcc=0;
for jj=1:s
    v1=find(c==jj);
    v=sum(p.labels(ind(v1))==l);
    
    if v>len
    lcc=jj;len=v;
    end
    
end


%    if (length(conn{jj})<2)
%        bad_tri=union(bad_tri,jj);
%    end
%end
p.labels(ind(c==lcc))=l;

end
 p.labels(p.labels==-1)=0;
%figure;
%patch('faces',p.faces,'vertices',p.vertices,'facevertexcdata',p.labels,'facecolor','flat','edgecolor','none')
surf1=p;
writedfs(sub_out,p);
%writedfs([surfname(1:end-3),'topcorr.dfs'],p);
