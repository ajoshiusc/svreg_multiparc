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



function [cs,c]=curvature_cortex_fast(FV,sigmoid_const,show_sigmoid,C)
% function [cs,c]=curvature_cortex_fast(FV,sigmoid_const,show_sigmoid,C)
%
% Calculate an approximation of the mean curvature of a surface. It calculates the mean angle between
% the surface normal of a vertex and the edges formed by the vertex and the
% neighbouring ones.
%
% Input:
%   FV: a faces/vertices structure
%   sigmoid_const: sigmoid constant (scalar 0-inf). The curvature 'cs' is weighted by a sigmoid to make a
%       sudden transition from convex to concave regions. Use small values
%       for linear transitions, and large (eg. 50) for sudden transitions
%   show_sigmoid: 1 to display the sigmoid function, 0 otherwise
%   C: connectivity matrix, see the new version of the vertices_connectivity function
%
%  Output:
%    cs: curvature of the surface, weighted by the sigmoid
%    c: curvature of the surface
%
% See also: VERTICES_CONNECTIVITY
%
% Authors: Dimitrios Pantazis, Anand Joshi, November 2007


nv = size(FV.vertices,1);

%get the edges for each vertex------------------------------------

%sparse matrix with the vertex coordinates in the diagonal
Dx=spdiags(FV.vertices(:,1),0,nv,nv);
Dy=spdiags(FV.vertices(:,2),0,nv,nv);
Dz=spdiags(FV.vertices(:,3),0,nv,nv);

%for each neighbor of the vertex, set the neighbor coordinates on the rows of Cx
Cx = C*Dx;
Cy = C*Dy;
Cz = C*Dz;

%for each neighbor of the vertex, set the vertex coordinates on the rows of Cx1. However, this is redundant, because it is the transpose of the above!
%Cx1=Dx*C; %transpose of Cx!
%Cy1=Dy*C;
%Cz1=Dz*C;

%get the edges, which is the neighbor coordinates minus the central vertex coordinates
Ex=Cx-Cx';
Ey=Cy-Cy';
Ez=Cz-Cz';

%make edges unit norm
En=sqrt(Ex.^2+Ey.^2+Ez.^2);
Eninv = spfun(@(x) 1./x , En); 
Ex = Ex.*Eninv;
Ey = Ey.*Eninv;
Ez = Ez.*Eninv;

%get the normal for each vertex------------------------------------
%hf=figure('Visible','off');
%hp.faces=FV.faces;
%hp.vertices=FV.vertices;
%h=patch(hp);
TR=TriRep(FV.faces,FV.vertices);
T2N=tri2nodes(FV);

%normals=get(h,'VertexNormals');
%close(hf);
normals=-T2N*TR.faceNormals;

[nrm,normalsnrm]=colnorm(normals');

%get inner product of normals with edges, which would be the cosine of an angle 0-180 degrees
Ip=spdiags(normalsnrm(1,:)',0,nv,nv)*Ex ...
    + spdiags(normalsnrm(2,:)',0,nv,nv)*Ey...
    + spdiags(normalsnrm(3,:)',0,nv,nv)*Ez;

%get angle and normalize it to -90 to 90 degrees
Ipacos = spfun(@(x) acos(x) , Ip);
c=sum(Ipacos,2)./sum(C,2) -pi/2;

%get sigmoid weighted curvature (for rough transitions from sulci to gyri)
cs= 1./(1+exp(-c.*sigmoid_const))-0.5;

%show sigmoid weighting function in required
if(exist('show_sigmoid'))
    if(show_sigmoid)
        x=-pi/2:0.01:pi/2;
        y=1./(1+exp(-x*sigmoid_const))-0.5;
        figure;
        plot(x,y)
        grid on;
        title('Transition between negative and positive curvature');
    end
end

