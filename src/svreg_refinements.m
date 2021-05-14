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


function svreg_refinements(subbasename,atlas_name,postfix,varargin)

subbasename = remove_extn_basename(subbasename);

[pth,subname,extt]=fileparts(subbasename);
if isempty(pth)
    pth=pwd();
    subbasename=fullfile(pth,subname,extt);
end

if ~exist('postfix','var')
    postfix='';
end
% check if postfix's first letter is -, if yes use it as flag
if ~isempty(postfix) && postfix(1) == '-'
    varargin{end+1}=postfix;
    postfix=[];
end

[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);

tmpdir=fullfile(pth,[subname,'.svreg.tmp']);

%mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);


%% Output a log
logfname=[subbasename,'.svreg.log'];
fp=fopen(logfname,'a+');
t = datestr(datetime('now'));
fprintf(fp,'%s:',t);
[svreg_version,svreg_build] = get_svreg_version(subbasename);
fprintf(fp,'SVReg %s(%s):',svreg_version,svreg_build);
fprintf(fp,'svreg_refinements %s %s %s ',subbasename, atlas_name, postfix);
for jjj=1:length(varargin)
    fprintf(fp,'%s ',varargin{jjj});
end
fprintf(fp,'\n');

fclose(fp);
%%



flags='';
for jj=1:size(varargin,2)
    flags=[flags,varargin{jj}];
end

if ~contains(flags,'v')
    verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1);
    verbosity= str2double(verbosity);
end


if exist('atlas_name','var')
    if atlas_name(1)=='-'
        flags=atlas_name;
        clear atlas_name;
    end
end

if ~exist('flags','var')
    flags='';
end
%disp1('Refining Volumetric ROIs','svreg_refinements');
refine_vol_labels(subbasename_tmp,postfix);
if isempty(postfix)|| contains(postfix,'USCBrain') || contains(postfix,'BCI-DNI') || contains(postfix,'USCLobes')
    correct_vol_labels(subbasename,postfix,flags);
else
    copyfile(sprintf('%s.svreg.%sref.label.nii.gz',subbasename_tmp,postfix),sprintf('%s.svreg.%slabel.nii.gz',subbasename,postfix),'f');
end

