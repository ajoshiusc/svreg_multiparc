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


function labs=get_hippo_label(xmlf)

aaa=xml2struct(xmlf);
ind=1;
labs=[];
for kk=1:1:length(aaa.labelset.label)
    if isempty(aaa.labelset.label{kk}.Attributes)% | length(aaa.Children(kk).Attributes(1).Value)<8
        % disp('h');
        continue;
    end
    name=aaa.labelset.label{kk}.Attributes.fullname;
    name=lower(name);
    h=~isempty(strfind(name,'hippo')); g=~isempty(strfind(name,'gyru'));
    s=~isempty(strfind(name,'sulc')); a=~isempty(strfind(name,'amygd'));
    if (h||a) && ~(s||g)
%        fprintf('%s\n',name);
        labs(ind)=str2num(aaa.labelset.label{kk}.Attributes.id);ind=ind+1;        
    end
end
