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


function refine_vol_labels(subbasename,postfix)

if ~exist('postfix','var')
    postfix='';
end

%gunzip([subbasename,'.svreg.label.nii.gz']);
vl=load_nii_z([subbasename,'.svreg.',postfix,'label.nii']);
%delete([subbasename,'.svreg.label.nii']);
%vmsk=load_nii_z([subname,'.cortex.dewisp.mask.nii']);
%ind_cortex_marked_as_wm=find(vmsk.img==0 & vl.img==2000);

sin=readdfs([subbasename,'.left.inner.cortex.svreg.',postfix,'dfs']);
smid=readdfs([subbasename,'.left.mid.cortex.svreg.',postfix,'dfs']);
spial=readdfs([subbasename,'.left.pial.cortex.svreg.',postfix,'dfs']);
spial2.vertices=0.5*(spial.vertices+smid.vertices);
indknl=(smid.labels~=0);
sinr=readdfs([subbasename,'.right.inner.cortex.svreg.',postfix,'dfs']);
smidr=readdfs([subbasename,'.right.mid.cortex.svreg.',postfix,'dfs']);
spialr=readdfs([subbasename,'.right.pial.cortex.svreg.',postfix,'dfs']);
spialr2.vertices=0.5*(spialr.vertices+smidr.vertices);
indknr=(smidr.labels~=0);
vl_new=vl;
% get ids of hippocampus amygdala etc
pth=fileparts(subbasename);

if existfile(fullfile(pth,'brainsuite_labeldescription.xml'))
    ids=get_hippo_label(fullfile(pth,'brainsuite_labeldescription.xml'));
else
    ids = -999;
end


if isempty(postfix)|| contains(postfix,'USCBrain') || contains(postfix,'BCI-DNI') || contains(postfix,'USCLobes')
    ind=find((vl_new.img>=100)&(vl_new.img<600)&(~ismember(vl_new.img,ids)));
else
    cort_labs = setdiff(union(unique(smidr.labels),unique(smid.labels)),0);
    ind = find(ismember(vl_new.img,cort_labs)&(~ismember(vl_new.img,ids)));
end
%ind=union(ind,ind_cortex_marked_as_wm);

[XX,YY,ZZ]=ind2sub(size(vl_new.img),ind);XX=XX-1;YY=YY-1;ZZ=ZZ-1;
dim=vl.hdr.dime.pixdim(2:4);


XX=XX.*dim(1);YY=YY.*dim(2);ZZ=ZZ.*dim(3);

sin.vertices=sin.vertices(indknl,:);smid.vertices=smid.vertices(indknl,:);spial.vertices=spial.vertices(indknl,:);spial2.vertices=spial2.vertices(indknl,:);
sinr.vertices=sinr.vertices(indknr,:);smidr.vertices=smidr.vertices(indknr,:);spialr.vertices=spialr.vertices(indknr,:);spialr2.vertices=spialr2.vertices(indknr,:);
smid.labels=smid.labels(indknl);smidr.labels=smidr.labels(indknr);
XXs=sin.vertices(:,1);YYs=sin.vertices(:,2);ZZs=sin.vertices(:,3);
XXs=[XXs;smid.vertices(:,1)];YYs=[YYs;smid.vertices(:,2)];ZZs=[ZZs;smid.vertices(:,3)];
XXs=[XXs;spial.vertices(:,1)];YYs=[YYs;spial.vertices(:,2)];ZZs=[ZZs;spial.vertices(:,3)];
XXs=[XXs;sinr.vertices(:,1)];YYs=[YYs;sinr.vertices(:,2)];ZZs=[ZZs;sinr.vertices(:,3)];
XXs=[XXs;smidr.vertices(:,1)];YYs=[YYs;smidr.vertices(:,2)];ZZs=[ZZs;smidr.vertices(:,3)];
XXs=[XXs;spialr.vertices(:,1)];YYs=[YYs;spialr.vertices(:,2)];ZZs=[ZZs;spialr.vertices(:,3)];
XXs=[XXs;spialr2.vertices(:,1)];YYs=[YYs;spialr2.vertices(:,2)];ZZs=[ZZs;spialr2.vertices(:,3)];
XXs=[XXs;spial2.vertices(:,1)];YYs=[YYs;spial2.vertices(:,2)];ZZs=[ZZs;spial2.vertices(:,3)];
aa=[XXs,YYs,ZZs]; clear XXs YYs ZZs;
[ss,ind1]=unique(aa,'rows');
val1=[smid.labels;smid.labels;smid.labels;smidr.labels;smidr.labels;smidr.labels;smidr.labels;smid.labels];
%warning off;
T= scatteredInterpolant(ss(:,1),ss(:,2),ss(:,3),val1(ind1));
%warning on;
T.Method='nearest';T.ExtrapolationMethod='nearest';
vl_new.img(ind)=T(XX(:),YY(:),ZZ(:));
save_untouch_nii_gz(vl_new,[subbasename,'.svreg.',postfix,'ref.label.nii']);
%gzip([subbasename,'.svreg.ref.label.nii']);
%delete([subbasename,'.svreg.ref.label.nii']);
%   view_nii(vl_new);
clear XX* YY* ZZ* si* sp* T ind
