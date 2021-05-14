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


function recolor_by_label(surfn,atlas_name,xmlf)



surf1=readdfs(surfn);
if ~exist('xmlf','var')
    a=fileparts(atlas_name);
    
    if exist(fullfile(a,'brainsuite_labeldescription.xml'),'file')
        xmlfname=fullfile(a,'brainsuite_labeldescription.xml');
    else
        xmlfname=[atlas_name,'brainsuite_labeldescription.xml'];
    end
    xmlf=xmlfname;
end
if ~exist(xmlf,'file')
    xmlf = [];
end

id=[];
if ~isempty(xmlf)
    aaa=xml2struct(xmlf);
    
    for kk=1:1:length(aaa.labelset.label)
        if isempty(aaa.labelset.label{kk}.Attributes)% | length(aaa.Children(kk).Attributes(1).Value)<8
            % disp('h');
            continue;
        end
        cl=aaa.labelset.label{kk}.Attributes.color;
        if strcmp(cl(1:2),'0x')
            clr{kk}=dec2hex(hex2dec(cl(3:end)),6);
        else
            clr{kk}=dec2hex(hex2dec(cl),6);
        end
        id(kk)=str2num(aaa.labelset.label{kk}.Attributes.id);
    end
end

lab=sort(unique(surf1.labels));
lab=setdiff(lab,0);

%new_colors = colorcube(round(length(lab)*10/8)); %
new_colors = distinguishable_colors(length(lab), [.5,.5,.5]); %hsv(1001);
%rng(1); % set random number generator

if isempty(xmlf)
    disp1('color not found in label description, using random color','recolor_by_label');
end

for l1=1:length(lab)
    l=lab(l1);iii=find(id==l);
    
    if isempty(iii) || isempty(xmlf)
        color1 = new_colors(l1,:);
        surf1.vcolor(surf1.labels==l,1) = color1(:,1);
        surf1.vcolor(surf1.labels==l,2) = color1(:,2);
        surf1.vcolor(surf1.labels==l,3) = color1(:,3);
    else
        id1=iii(1);
        surf1.vcolor(surf1.labels==l,3)=hex2dec(clr{id1}(5:6))/256;
        surf1.vcolor(surf1.labels==l,2)=hex2dec(clr{id1}(3:4))/256;
        surf1.vcolor(surf1.labels==l,1)=hex2dec(clr{id1}(1:2))/256;
    end
    
end
surf1.vcolor(surf1.labels==0,1)=.5;
surf1.vcolor(surf1.labels==0,2)=.5;
surf1.vcolor(surf1.labels==0,3)=.5;
writedfs(surfn,surf1);
