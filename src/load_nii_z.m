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


function v=load_nii_z(fname)

if strcmp(fname(end-2:end),'.gz')
    fname=fname(1:end-3);
    %error('File extension sent in is not nii! exiting..')
end

if strcmp(fname(end-3:end),'nii')
    error('File extension sent in is not nii! exiting..')
end
warning off;
if exist(fname,'file')
    v=load_nii_BIG_Lab(fname);%load_nii(fname, [], [], [], [], [], 1);
elseif exist([fname,'.gz'],'file')
%     gunzip([fname,'.gz']);
%     v=load_nii_BIG_Lab(fname);%load_nii(fname, [], [], [], [], [], 1);
%     %v=read_nifti_gz([fname,'.gz']);
%     delete(fname);    
    v=load_nii_BIG_Lab([fname,'.gz']);
else
    error('file:%s.gz doesn''t exist. exiting',fname);
end
warning on;

