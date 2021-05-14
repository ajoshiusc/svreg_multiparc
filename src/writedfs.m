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


function writedfs(s, NFV)
% WRITEDFS2 Writes a Duff Surface file (dfs).
%   WRITEDFS2(FILENAME,NFV) writes the file specified by FILENAME string.
%
% DFS has the following structure:
%   NFV.faces        : the face data,
%   NFV.vertices     : the vertex positions,
%   NFV.normals      : not currently included
%   NFV.uv           : the uv coordinates,
%   NFV.vcolor       : the vertex color data (r,g,b) in ([0-1],[0-1],[0-1])
%   NFV.labels       : vertex label (int16)
%   NFV.attributes   : vertex attribute (float)
% Author : David Shattuck (shattuck@loni.ucla.edu)
% updated 21-April-2010
%
% [000-011]	char headerType[12]; // should be DFS_BE v2.0\0 on big-endian machines, DFS_LEv1.0\0 on little-endian
% [012-015] int32 hdrsize;			// Size of complete header (i.e., offset of first data element)
% [016-010] int32 mdoffset;			// Start of metadata.
% [020-023] int32 pdoffset;			// Start of patient data header.
% [024-027] int32 nTriangles;		// Number of triangles
% [028-031] int32 nVertices;		// Number of vertices
% [032-035] int32 nStrips;			// Number of triangle strips (deprecated)
% [036-039] int32 stripSize;		// size of strip data  (deprecated)
% [040-043] int32 normals;			// 4	Int32	<normals>	Start of vertex normal data (0 if not in file)
% [044-047] int32 uvoffset;			// Start of surface parameterization data (0 if not in file)
% [048-051] int32 vcoffset;			// vertex color
% [052-055] int32 labelOffset;	// vertex labels
% [056-059] int32 vertexAttributes; // vertex attributes (float32 array of length NV)
% [060-183] uint8 pad2[4 + 15*8]; // formerly 4x4 matrix, affine transformation to world coordinates, now used to add new fields
if exist(s,'file')
    delete(s);
end

fid = fopen(s,'wb','ieee-le');
if (fid<0) 
   error('BDP:FileOpenFailed', 'BDP could not open file for writing DFS file:%s',s);
end;
magic = ['D' 'F' 'S' '_' 'L' 'E' ' ' 'v' '2' '.' '0' 0]'; % DFS_LEv2.0\0
hdrsize = 184;
mdoffset = 0;		% Start of metadata.
pdoffset = 0;       % Start of patient data header.
nTriangles = length(NFV.faces(:))/3;
nVertices  = length(NFV.vertices(:))/3;
nStrips = 0;
stripSize = 0;
normals = 0;
uvoffset = 0;
vcoffset = 0;
precision = 0;
labelOffset = 0;
attributes = 0;
pad=[0 0 0];
orientation=eye(4);
nextarraypos = hdrsize + nTriangles * 12 + nVertices * 12; % start the fields at the after the header
if (isfield(NFV,'normals'))
    normals = nextarraypos;
    nextarraypos = nextarraypos + nVertices * 12; % 12 bytes per normal vector (3 x float32)
end;
if (isfield(NFV,'vcolor'))
    vcoffset = nextarraypos;
    nextarraypos = nextarraypos + nVertices * 12; % 12 bytes per color coordinate (3 x float32)
end;
if (isfield(NFV,'u')&&isfield(NFV,'v'))
    uvoffset = nextarraypos;
    nextarraypos = nextarraypos + nVertices *  8; % 8 bytes per uv coordinate (2 x float32)
end;
if (isfield(NFV,'labels'))
    labelOffset = nextarraypos;
    nextarraypos = nextarraypos + nVertices * 2; % 2 bytes per label (int16)
end;
if (isfield(NFV,'attributes'))
    attributes = nextarraypos;
    nextarraypos = nextarraypos + nVertices * 4; % 4 bytes per attribute (float32)
end;

fwrite(fid,magic,'char');
fwrite(fid,hdrsize,'int32');
fwrite(fid,mdoffset,'int32');
fwrite(fid,pdoffset,'int32');
fwrite(fid,nTriangles,'int32');
fwrite(fid,nVertices,'int32');
fwrite(fid,nStrips,'int32');
fwrite(fid,stripSize,'int32');
fwrite(fid,normals,'int32');
fwrite(fid,uvoffset,'int32');
fwrite(fid,vcoffset,'int32');
fwrite(fid,labelOffset,'int32');
fwrite(fid,attributes,'int32');
fwrite(fid,zeros(1,4+15*8),'uint8');
fwrite(fid,(NFV.faces-1)','int32');
fwrite(fid,(NFV.vertices)','float32');
if (normals>0)
    %disp('writing normals');
    fwrite(fid,NFV.normals','float32');
end;
if (vcoffset>0)
    %disp('writing color');
    fwrite(fid,NFV.vcolor','float32');
end;
if (uvoffset>0)
    %disp('writing uv');
    fwrite(fid,[NFV.u(:) NFV.v(:)]','float32');
end;
if (labelOffset>0)
    %disp('writing labels');
    fwrite(fid,NFV.labels,'int16');
end;
if (attributes>0)
    %disp('writing attributes');
    fwrite(fid,NFV.attributes,'float32');
end;   
fclose(fid);
end
