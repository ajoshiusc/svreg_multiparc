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




function correct_vol_labels(subbasename,postfix,varargin)
[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);
tmpdir=fullfile(pth,[subname,'.svreg.tmp']);

% [pth,subname]=fileparts(subbasename);
% tmpdir=fullfile(pth,[subname,'.svreg.tmp']);
%mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);

flags=[];
for jj=1:size(varargin,2)
    flags=[flags,varargin{jj}];
end
%  flags=strrep(flags,'-','');
%  a=strfind(flags,'v');
if isempty(strfind(flags,'v'))
    verbosity=2;
else
    a=strfind(flags,'v');
    verbosity=flags(a(1)+1);
    verbosity= str2double(verbosity);
end


%gunzip(sprintf('%s.svreg.ref.label.nii.gz',subbasename));
vl=load_nii_z(sprintf('%s.svreg.%sref.label.nii',subbasename_tmp,postfix));vlo=vl;
%delete(sprintf('%s.svreg.ref.label.nii',subbasename));

%gunzip([subbasename,'.cortex.dewisp.mask.nii.gz']);
vmsk=load_nii_z([subbasename,'.cortex.dewisp.mask.nii']);
%delete([subbasename,'.cortex.dewisp.mask.nii']);

ind=find((vl.img>=100)&(vl.img<600));
vpvc=load_nii_z(sprintf('%s.pvc.frac.nii',subbasename));
subind=find(vmsk.img(ind)>0);
vl.img=double(vl.img).*double(vpvc.img>0);
vl.img(ind(subind))=2000;
save_untouch_nii_gz(vl,sprintf('%s.svreg.%swm.label.nii',subbasename_tmp,postfix));vlwm=vl;

%gzip(sprintf('%s.svreg.wm.label.nii',subbasename_tmp));

%delete(sprintf('%s.svreg.wm.label.nii',subbasename_tmp));
v=vlo;
%ind1=find(vlo.img>790);vlo.img(ind1)=0;
v.img = medfilt3(vlo.img,3);
subind=find(vmsk.img(ind)==0);
v.img(subind)=vlo.img(subind);
indsubcor=find((vlo.img<100)|(vlo.img>600));
v.img(indsubcor)=vlo.img(indsubcor);
lab=unique(v.img(:));
%fprintf('Correcting volumetric labels\n');%v2=v;
%delete non connected components
for l1=1:length(lab)
    if verbosity>1
        disp1(sprintf('TopCorrLab: %d/%d',l1,length(lab)),'svreg_refinements',flags);
    end
    l=lab(l1);
    img=double(l)*(v.img==l);
    img=imfill(img,6,'holes');
    
    np=length(find(img>0));
    im=bwareaopen(img,round(np/2),26);
    v.img(img>0)=double(l)*im(img>0);%aaa(l1)=sum(im(img>0))
    
    %    fprintf('corrected %d / %d labels\n',l1,length(lab));
end
%  v.img=vo.img-v.img;
%save aaa aaa v
cortical_rois=unique([lab(lab<670)',850,701,720,721,614,615,616,617,612,613,630]);
non_cortical_rois=unique([900,760,780]);

cerebrum_mask=load_nii_z([subbasename,'.cerebrum.mask.nii.gz']);
if isempty(strfind(flags,'C'))
    
    spial1=readdfs([subbasename,'.pial.cortex.dfs']);
    if strfind(flags,'D')
        aa=strfind(flags,'D');
        msk_width=str2double(flags(aa+1));
    else
        msk_width=1;
    end
    %    msk_width=msk_width+2;
    msk=surf2mask(spial1,cerebrum_mask,msk_width);
    if sum(msk(:)>0) < .5*sum(cerebrum_mask.img(:)>0)
        disp1('Error in generating pial surface mask, skipping the pial surface based correction','correct_vol_labels',flags);
        msk=cerebrum_mask.img;
    else
        %   lgth_cbm=sum(cerebrum_mask.img>0);
        cerebrum_mask.img=255*double(cerebrum_mask.img>0).*double((msk>0));
        msk=cerebrum_mask.img;
        %cerebrum_mask.img=255*double(msk>0);
        % disp1('pial surface mask is set to be intersection of cerebrum mask and pial surface mask','correct_vol_labels',flags);
        save_untouch_nii_gz(cerebrum_mask,[subbasename_tmp,'.pial.mask.nii.gz']);
    end
end
v.img(ismember(v.img,non_cortical_rois) & cerebrum_mask.img>0 & v.img~=2000)=0;
v.img(ismember(v.img,cortical_rois) & cerebrum_mask.img==0)=0;


%ind12=find(v.img>0);
ind12=find((v.img~=0)&~ismember(v.img,non_cortical_rois)&cerebrum_mask.img>0 & v.img~=2000);
[XX,YY,ZZ]=ind2sub(size(vlo.img),ind12);%XX=XX-1;YYu=YYu-1;ZZu=ZZu-1;

F = scatteredInterpolant(XX,YY,ZZ,double(v.img(ind12)),'nearest'); clear XX YY ZZ
%F.Method='nearest';
indd=find(cerebrum_mask.img>0 & (v.img==0));

[XXu,YYu,ZZu]=ind2sub(size(vlo.img),indd);%XXu=XXu-1;YYu=YYu-1;ZZu=ZZu-1;

%v.img(indd)=griddata(XX,YY,ZZ,double(v.img(ind12)),XXu+.1,YYu+.2,ZZu+.3,'nearest');%
v.img(indd)=F(XXu+.753,YYu+.352,ZZu+.551); clear XXu YYu ZZu F
%save aaa2 aaa v indd



%%%%%%%
ind12=find((v.img~=0)&~ismember(v.img,cortical_rois)&cerebrum_mask.img==0);
[XX,YY,ZZ]=ind2sub(size(vlo.img),ind12);%XX=XX-1;YYu=YYu-1;ZZu=ZZu-1;

F = scatteredInterpolant(XX,YY,ZZ,double(v.img(ind12)),'nearest'); clear XX YY ZZ
%F.Method='nearest';
indd=find((cerebrum_mask.img==0&vpvc.img>0) & (v.img==0));

[XXu,YYu,ZZu]=ind2sub(size(vlo.img),indd);%XXu=XXu-1;YYu=YYu-1;ZZu=ZZu-1;

if ~isempty(indd) && ~isempty(ind12)
    v.img(indd)=F(XXu+.753,YYu+.352,ZZu+.551); clear XXu YYu ZZu F
end
%%%%%%%




v.img=double(v.img).*double(vpvc.img>0);

save_untouch_nii_gz(v,sprintf('%s.svreg.%scorr.label.nii',subbasename_tmp,postfix));
%gzip(sprintf('%s.svreg.corr.label.nii',subbasename_tmp));
%delete(sprintf('%s.svreg.corr.label.nii',subbasename_tmp));

%copyfile(sprintf('%s.svreg.corr.label.nii.gz',subbasename_tmp),sprintf('%s.svreg.corr.label.nii.gz',subbasename),'f');

vl=v;
ind=find((vl.img>=100)&(vl.img<600));
subind=find(vmsk.img(ind)>0);
vl.img(vl.img==3)=2000;
vl.img(ind)=vl.img(ind)+1000;
vl.img(ind(subind))=vl.img(ind(subind))+1000;

if contains(flags,'C')
    vl.img=double(vl.img).*double(vpvc.img>0);
else
    vl.img(ismember(vl.img,cortical_rois)|vl.img>1000)=vl.img(ismember(vl.img,cortical_rois)|vl.img>1000).*double(msk(ismember(vl.img,cortical_rois)|vl.img>1000)>0);
    
end
vvll=load_nii_z(sprintf('%s.label.surfreg.nii',subbasename_tmp));
msk_full=double(imdilate(vvll.img,ones(3,3,3)));
msk_full((vl.img~=740) & (ismember(msk_full,cortical_rois)|cerebrum_mask.img>0))=0;
vl.img(~(ismember(vl.img,cortical_rois)|vl.img>1000))=vl.img(~(ismember(vl.img,cortical_rois)|vl.img>1000)).*double(msk_full(~(ismember(vl.img,cortical_rois)|vl.img>1000))>0);
vlwm.img=imdilate(255*(vlwm.img==740),ones(10,10,10));
vl.img((vl.img==740)& (vlwm.img==0))=0;
save_untouch_nii_gz(vl,sprintf('%s.svreg.%sdws.label.nii',subbasename_tmp,postfix));
%gzip(sprintf('%s.svreg.dws.label.nii',subbasename_tmp));
%delete(sprintf('%s.svreg.dws.label.nii',subbasename_tmp));


copyfile(sprintf('%s.svreg.%sdws.label.nii.gz',subbasename_tmp,postfix),sprintf('%s.svreg.%slabel.nii.gz',subbasename,postfix),'f');

