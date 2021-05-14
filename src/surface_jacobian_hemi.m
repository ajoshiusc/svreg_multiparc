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


function surface_jacobian_hemi(subbasename,hemi)
% This function computes surface jacobian for a given hemisphere of mapping 
% from atlas to subject.
% The value is stored at every point on the atlas mesh.
% The function returns absolute value of the Jacobian determinant.
% Input: subbasename: subjects file prefix
% Output is saved in atlas.hemi.mid.cortex.jacobian.dfs.
% The surface is color coded by Jacobian in hot color scheme and can be
% seen in BrainSuite. Also smoothed atlas coordinates are also saved for
% easy visualization.

    pth=fileparts(subbasename);
    sub=readdfs([subbasename,'.',hemi,'.mid.cortex.svreg.dfs']);
 %   sub=clean_sqr_map(sub);
    atlas=readdfs(fullfile(pth,['atlas.',hemi,'.mid.cortex.svreg.dfs']));
    clear V
    V(:,1)=map_data_flatmap(sub,sub.vertices(:,1),atlas);
    V(:,2)=map_data_flatmap(sub,sub.vertices(:,2),atlas);
    V(:,3)=map_data_flatmap(sub,sub.vertices(:,3),atlas);
    
    V1=V(atlas.faces(:,2),:)-V(atlas.faces(:,1),:);
    V2=V(atlas.faces(:,3),:)-V(atlas.faces(:,1),:);
    
    Z=cross(V1,V2);
    Z=Z./repmat(mynorm(Z),1,3);
    
    X=V1./repmat(mynorm(V1),1,3);
    Y=cross(Z,X);
    
    v1x=dot(X',V1')';v1y=dot(Y',V1')';
    v2x=dot(X',V2')';v2y=dot(Y',V2')';
    
    
    
    V1=atlas.vertices(atlas.faces(:,2),:)-atlas.vertices(atlas.faces(:,1),:);
    V2=atlas.vertices(atlas.faces(:,3),:)-atlas.vertices(atlas.faces(:,1),:);
    
    Z=cross(V1,V2);
    Z=Z./repmat(mynorm(Z),1,3);
    
    X=V1./repmat(mynorm(V1),1,3);
    Y=cross(Z,X);
    
    u1x=dot(X',V1')';u1y=dot(Y',V1')';
    u2x=dot(X',V2')';u2y=dot(Y',V2')';
    
    detU=u1x.*u2y - u2x.*u1y;
    
    
    j11=(1./detU).*(u2y.*v1x-u2x.*v1y);
    j12=(1./detU).*(u2y.*v2x-u2x.*v2y);
    j21=(1./detU).*(-u1y.*v1x+u1x.*v1y);
    j22=(1./detU).*(-u1y.*v2x+u1x.*v2y);
    Jdet=j22.*j11-j12.*j21;
    
    Jdet=abs(Jdet);
    T2V=tri2nodes(atlas);
    Jdet=T2V*Jdet;
    
    atlas.attributes=Jdet;
    atlas=smooth_cortex_fast(atlas,.5,2000);
    % atlas.vertices=V;
    cbar=hot(1000); cind=1+round(999*min(Jdet,3)/3);
    atlas.vcolor=cbar(cind,:);
    writedfs(fullfile(pth,['atlas.',hemi,'.mid.cortex.jacobian.dfs']),atlas);
    
    
    

function nrm=mynorm(W)

nrm=sqrt(W(:,1).^2 + W(:,2).^2 + W(:,3).^2);

