function [version,build] = get_svreg_version(subbasename, atlasbasename)


if exist('atlasbasename','var')
    at_pth = fileparts(atlasbasename);
    svreg_pth = fileparts(at_pth);
    fname = fullfile(svreg_pth,'svregmanifest.xml');
else
    pth = fileparts(subbasename);
    fname = fullfile(pth,'svregmanifest.xml');
end

if existfile(fname)
x = xml2struct(fname);

version = x.svregmanifest.version.Text;

build = x.svregmanifest.build.Text;

else
    
    fprintf('SVReg version used to process subject %s could not be determined. Proceeding...\n',subbasename);

    version = '';
    build = '';
    
end