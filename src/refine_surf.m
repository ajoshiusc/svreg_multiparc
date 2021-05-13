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


function s=refine_surf(s)

newvert=(1/3)*(s.vertices(s.faces(:,1),:)+s.vertices(s.faces(:,2),:)+s.vertices(s.faces(:,3),:));

nV=length(s.vertices);nVer=length(newvert);
if isfield(s,'labels')
    s.labels=[s.labels;median(s.labels(s.faces),2)];
end
s.vertices=[s.vertices;newvert];

s.faces=[[s.faces(:,2),nV+[1:nVer]',s.faces(:,1)];[s.faces(:,3),nV+[1:nVer]',s.faces(:,2)];[s.faces(:,1),nV+[1:nVer]',s.faces(:,3)]];



