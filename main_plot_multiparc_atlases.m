clc;clear all;close all;restoredefaultpath;

addpath('src');

uscbrain_multi_atlas = '/ImagePTE1/ajoshi/code_farm/svreg/USCBrainMulti';%correct this
subbasename = '/home/ajoshi/Desktop/anat/sub-OAS30009_ses-d0148_run_02_T1w';% correct this
BrainSuitePath = '/home/ajoshi/BrainSuite21a'; % correct this


lmid = readdfs(fullfile(uscbrain_multi_atlas,'USCBrain.left.mid.cortex.dfs'));
rmid = readdfs(fullfile(uscbrain_multi_atlas,'USCBrain.right.mid.cortex.dfs'));


l = dir(uscbrain_multi_atlas);


for k = 3:length(l)
    atlas_dir = fullfile(uscbrain_multi_atlas,l(k).name);

    if ~isfolder(atlas_dir)
        continue;
    end

    disp(atlas_dir);


    atd = dir([atlas_dir,'/*.label.nii.gz']);

    if length(atd)<1
        continue;
    end
    atlasbasename = fullfile(atd(1).folder,atd(1).name);

    a = regexp(atlasbasename, '.label.nii.gz', 'split');
    atlasbasename = a{1};

    [d,n]=fileparts(a{1});
    [~,atlas_name] = fileparts(d);% n(5:end);
    if strcmp(atlas_name,'Schaefer2018')
        atlas_name = n(9:end);
    end
    %fprintf('Processing Atlas:%s\natlasbasename:%s\n------\n',atlas_name,atlasbasename);

    atlas_left=readdfs([atlasbasename,'.left.mid.cortex.dfs']);
    atlas_right=readdfs([atlasbasename,'.right.mid.cortex.dfs']);

    xmlfile = fullfile(atlas_dir,'brainsuite_labeldescription.xml');
    if ~exist("xmlfile",'file')
        disp('XML FILE NOT FOUND');
        disp(xmlfile);
    else
        xmlfile = fullfile(uscbrain_multi_atlas,'brainsuite_labeldescription.xml');
    end


    atlas_left.vertices = lmid.vertices;
    atlas_right.vertices = rmid.vertices;

    atlas_left_file = 'tmpleft.dfs';
    writedfs(atlas_left_file,atlas_left);
    atlas_right_file = 'tmpright.dfs';
    writedfs(atlas_right_file,atlas_right);


    recolor_by_label(atlas_left_file,[],xmlfile);

    recolor_by_label(atlas_right_file,[],xmlfile);

    atlas_left = readdfs(atlas_left_file);
    atlas_right = readdfs(atlas_right_file);

    %h=figure; 
    h=figure('Position', [10 10 900 1000]);

    hold on;

    patch('faces',atlas_left.faces,'Vertices',atlas_left.vertices,'facevertexcdata',atlas_left.vcolor,'edgecolor','none','facecolor','flat');
    patch('faces',atlas_right.faces,'Vertices',atlas_right.vertices,'facevertexcdata',atlas_right.vcolor,'edgecolor','none','facecolor','flat');

    
    %light("Position",[-100 50 300]);
    %light("Position",[-100 50 450]);
    %light("Position",[200 50 450]);

    axis tight;axis equal;view(0,90);material dull;axis off;axis vis3d;camlight;

    saveas(h,[atlas_name,'.png']);
    close all;

end
%
%
%
%
% a=tic;
% svreg_multiparc(subbasename,uscbrain_multi_atlas,BrainSuitePath,'USCBrain_BT');
% toc(a)



