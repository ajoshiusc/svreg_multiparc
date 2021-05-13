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



function VertConn = vertices_connectivity(FV,VERBOSE);
%VERTICES_CONNECTIVITY Generate the connections between vertices
% function VertConn = vertices_connectivity(FV,VERBOSE);
% function VertConn = vertices_connectivity(FV);
% FV is the standard matlab structure for faces and vertices,
%  where FV.faces is m x 3, and FV.vertices is n x 3.
%
% VertConn returned is vector of cells, one-to-one with each row of FV.vertices.
% VertConn{i} returns a row vector of the vertex numbers (rows in FV.vertices) that
%  are connected by faces to the ith vertex row in FV.vertices.
%
% Thus if we want to 'swell' the region around a vertex, VertConn{i} gives us the 
%  vertex numbers of those vertices that are adjacent.
%
% See also FACES_CONNECTIVITY

%<autobegin> -------- 03-Jul-2002 17:44:39 ------------------------------
% ----------- Automatically Generated Comments Block -----------------
%
% At Check-in: $Author: ajoshi $  $Revision: 1.1 $  $Date: 2007-10-20 11:19:51 $
% Contributions Dimitrios Pantazis
% Copyright (c) 2002 BrainStorm MMII
% Source code may not be distributed in original or altered form.
% See bst_splashscreen, http://neuroimage.usc.edu, or email leahy@sipi.usc.edu
%   for license and copyright notices.
%<autoend> ---------- 03-Jul-2002 17:44:39 ------------------------------


% John C. Mosher, Ph.D.
% 19-Nov-99 Based on May 1998 scripts.
% <copyright>
% <copyright>

if(~exist('VERBOSE','var')),
   VERBOSE = 0; % default non-silent running of waitbars
end

nv = size(FV.vertices,1);
[nf,ns] = size(FV.faces); % number of faces, number of sides per face

VertConn = cell(nv,1); % one empty cell per vertex

if(VERBOSE)
   % disp(sprintf('Processing %.0f faces',nf))
   hwait = waitbar(0,sprintf('Processing the Vertex Connectivity for %.0f faces',nf));
   drawnow %flush the display
end

for iv = 1:nf, % use each face's information
   if(VERBOSE)
      if(~rem(iv,round(nf/10))), % ten updates
         % fprintf(' %.0f',iv);
         waitbar(iv/nf,hwait);
         drawnow %flush the display         
      end
   end
   for i = 1:ns, %each vertex of the face
      for j = 0:(ns-2), % each additional vertex
         VertConn{FV.faces(iv,i)}(end+1) = FV.faces(iv,rem(i+j,ns)+1);
      end
   end
end

if(VERBOSE)
    close(hwait);
   hwait = waitbar(0,sprintf('Now sorting the vertex results'));
   drawnow %flush the display
end

for i = 1:nv,
   if(VERBOSE)
      if(~rem(i,round(nv/10))), % ten updates
         waitbar(i/nv,hwait);
         drawnow %flush the display         
      end
   end
   VertConn{i} = unique(VertConn{i});
end
if(VERBOSE)
close(hwait);
end

return
