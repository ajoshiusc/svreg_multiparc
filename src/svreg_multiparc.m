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

function svreg_multiparc(subbasename,multi_dir,BrainSuitePath, atlas_name)
% atlas_name can be 'all' or whichever atlas you want to use

subbasename=remove_extn_basename(subbasename);

[pth,subname,extt]=fileparts(subbasename);
if isempty(pth)
    pth=pwd();
    subbasename=fullfile(pth,subname,extt);
end

if (nargin < 3)
    fprintf('USAGE: svreg_multiparc.sh subbasename multi_dir BrainSuitePath atlas_name\n');
    fprintf('subbasename: subjectbasename as in svreg command line\n');
    fprintf('multi_dir: The new multi atlas\n');
    fprintf('BrainSuitePath: path of BrainSuite installation\n');
    fprintf('atlas_name can be ''all'' or whichever atlas you want to use\n');
end

if existfile([subbasename,'.svreg.map.nii.gz'])
    vol_lab_done = 1;
else
    vol_lab_done = 0;
end

[pth,subname,extt]=fileparts(subbasename);
subname=strcat(subname,extt);

tmpdir=fullfile(pth,[subname,'.svreg.tmp']);

%mkdir(tmpdir);
subbasename_tmp=fullfile(tmpdir,subname);

logfname=[subbasename,'.svreg.log'];
fp=fopen(logfname,'a+');
fprintf(fp,'svreg_multi_parc %s %s %s %s\n',subbasename,multi_dir,BrainSuitePath,atlas_name);
fprintf(fp,'\n');

if strcmp(atlas_name,'all')
    atd = dir([multi_dir,'/*/*.label.nii.gz']);
else
    %atd=struct('name', {fullfile(multi_dir,atlas_name)});
    atd = dir([fullfile(multi_dir,atlas_name),'/*.label.nii.gz']);
end

subpth = fileparts(subbasename);



for j = 1:length(atd)
    atlasbasename = fullfile(atd(j).folder,atd(j).name);
    a = regexp(atlasbasename, '.label.nii.gz', 'split');
    atlasbasename = a{1};
    [d,n]=fileparts(a{1});
    [~,atlas_name] = fileparts(d);% n(5:end);
    if strcmp(atlas_name,'Schaefer2018')
        atlas_name = n(9:end);
    end
    fprintf('Processing Atlas:%s\natlasbasename:%s\n------\n',atlas_name,atlasbasename);

    % label surfaces
    sl=readdfs([subbasename,'.left.mid.cortex.svreg.dfs']);
    al=readdfs(fullfile(subpth,'atlas.left.mid.cortex.svreg.dfs'));
    new_al=readdfs([atlasbasename,'.left.mid.cortex.dfs']);

    sl.labels=map_data_flatmap(al, new_al.labels, sl, 'nearest');

    slin=readdfs([subbasename,'.left.inner.cortex.svreg.dfs']);
    slin.labels=sl.labels;

    slpial=readdfs([subbasename,'.left.pial.cortex.svreg.dfs']);
    slpial.labels=sl.labels;


    sr=readdfs([subbasename,'.right.mid.cortex.svreg.dfs']);
    ar=readdfs(fullfile(subpth,'atlas.right.mid.cortex.svreg.dfs'));
    new_ar=readdfs([atlasbasename,'.right.mid.cortex.dfs']);

    sr.labels=map_data_flatmap(ar, new_ar.labels, sr, 'nearest');



    srin=readdfs([subbasename,'.right.inner.cortex.svreg.dfs']);
    srin.labels=sr.labels;

    srpial=readdfs([subbasename,'.right.pial.cortex.svreg.dfs']);
    srpial.labels=sr.labels;

    %if ~exist(subbasename_tmp,'dir')
    p2=fileparts(subbasename_tmp);

    if exist(tmpdir,'dir')        
        rmdir(tmpdir,'s');
    end

    mkdir(tmpdir);
    p1=fileparts(subbasename);
    p1at=fileparts(atlasbasename);
    
    atlas_xml = fullfile(p1at,'brainsuite_labeldescription.xml');
    
    if exist(atlas_xml,'file')
        copyfile(atlas_xml,fullfile(p2,'brainsuite_labeldescription.xml'));        
        xml_fname = fullfile(p1,['brainsuite_labeldescription.',atlas_name,'.xml']);
        copyfile(fullfile(p2,'brainsuite_labeldescription.xml'),xml_fname);    
   % else
    %    atlas_xml = fullfile(at_pth,'brainsuite_labeldescription.xml');
    end
    

    if vol_lab_done    
        copyfile(sprintf('%s.svreg.init.label.nii.gz',subbasename),sprintf('%s.label.surfreg.nii.gz',subbasename_tmp));
    end
    %subbasename_tmp=subbasename;
    slout=[subbasename_tmp,'.left.mid.cortex.reg.',atlas_name,'dfs'];
    srout=[subbasename_tmp,'.right.mid.cortex.reg.',atlas_name,'dfs'];
    sloutin=[subbasename_tmp,'.left.inner.cortex.svreg.',atlas_name,'dfs'];
    sroutin=[subbasename_tmp,'.right.inner.cortex.svreg.',atlas_name,'dfs'];
    sloutp=[subbasename_tmp,'.left.pial.cortex.svreg.',atlas_name,'dfs'];
    sroutp=[subbasename_tmp,'.right.pial.cortex.svreg.',atlas_name,'dfs'];

    writedfs(slout,sl);writedfs(sloutin,slin);writedfs(sloutp,slpial);
    writedfs(srout,sr);writedfs(sroutin,srin);writedfs(sroutp,srpial);


     
    hemi={'left','right'};
    parfor h=1:2
        
        if contains(atlas_name,'USCBrain') || contains(atlas_name,'USCLobes') || contains(atlas_name,'BCI-DNI')            
            refine_ROIs2(subbasename,hemi{h},atlas_name);
         %   delete([subbasename,'.',hemi{h},'.mid.cortex.svreg.',atlas_name,'dfs']);
            delete([subbasename,'.',hemi{h},'.inner.cortex.svreg.',atlas_name,'dfs']);
            delete([subbasename,'.',hemi{h},'.pial.cortex.svreg.',atlas_name,'dfs']);            
        else
            copyfile([subbasename_tmp,'.',hemi{h},'.mid.cortex.reg.',atlas_name,'dfs'],[subbasename_tmp,'.',hemi{h},'.mid.cortex.svreg.',atlas_name,'dfs'],'f');
            copy_attrib_colors(subbasename_tmp,hemi{h},['svreg.',atlas_name,'dfs']);            
            copyfile([subbasename_tmp,'.',hemi{h},'.mid.cortex.reg.',atlas_name,'dfs'],[subbasename,'.',hemi{h},'.mid.cortex.svreg.',atlas_name,'dfs'],'f');
        end
        
    end
  
    slout=[subbasename,'.left.mid.cortex.svreg.',atlas_name,'dfs'];
    srout=[subbasename,'.right.mid.cortex.svreg.',atlas_name,'dfs'];

    xmlf = fullfile(pth,['brainsuite_labeldescription.',atlas_name,'.xml']);
    if ~exist(xmlf,'file')
        xmlf = [];%fullfile(pth,'brainsuite_labeldescription.xml');
    end

    recolor_by_label(slout,atlasbasename,xmlf);
    recolor_by_label(srout,atlasbasename,xmlf);

    if vol_lab_done
        vmap=load_nii_z([subbasename,'.svreg.map.nii.gz']);
        vsl=load_nii_z([atlasbasename,'.label.nii.gz']);
        vsl_sub=load_nii_z([subbasename,'.svreg.label.nii.gz']);

        xmap2=vmap.img(:,:,:,1);
        ymap2=vmap.img(:,:,:,2);
        zmap2=vmap.img(:,:,:,3);
        vsl_sub.img=interp3(vsl.img,(ymap2),(xmap2),(zmap2),'nearest',0);

        save_untouch_nii_gz(vsl_sub,sprintf('%s.svreg.%slabel.nii.gz',subbasename_tmp,atlas_name));
    end
    
    if ~exist(fullfile(p1,'multiparc'),'dir')
        mkdir(fullfile(p1,'multiparc'));
    end
    
    if ~isempty(xmlf)
        movefile(xmlf,fullfile(p1,'multiparc',['brainsuite_labeldescription.',atlas_name,'.xml']));
    end
    
    if vol_lab_done 
        svreg_refinements(subbasename,atlasbasename,atlas_name);
    end

    [pth, sub]=fileparts(subbasename);
    subbasename_out=fullfile(pth,'multiparc',sub);
    
    slout2=[subbasename_out,'.left.mid.cortex.svreg.',atlas_name,'.dfs'];
    srout2=[subbasename_out,'.right.mid.cortex.svreg.',atlas_name,'.dfs'];

    movefile(slout,slout2);
    movefile(srout,srout2);
    
    if vol_lab_done
        movefile(sprintf('%s.svreg.%slabel.nii.gz',subbasename,atlas_name), sprintf('%s.svreg.%s.label.nii.gz',subbasename_out,atlas_name));
    end

    if exist(tmpdir,'dir')        
        rmdir(tmpdir,'s');
    end

    fprintf('Done!\n');

end


