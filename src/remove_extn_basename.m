function fileName = remove_extn_basename(fileName)



ext = '';

if length(fileName)>=3 && strcmpi(fileName(end-2:end), '.gz')
   ext = [fileName(end-2:end) ext];
   fileName = fileName(1:end-3);   
end

while length(fileName)>=4 && ( ...
      strcmpi(fileName(end-3:end), '.nii') || strcmpi(fileName(end-3:end), '.img') || ...
      strcmpi(fileName(end-3:end), '.hdr') )
   
   ext = [fileName(end-3:end) ext];
   fileName = fileName(1:end-4);
end


% 
% extn = {'.nii','.nii.gz','.img','.hdr'};
% 
% for e = 1:length(extn)
%     ext = extn{e};
%    
%     l = length(ext);
%     if strcmp(ext,subbasename(end-l+1:end))
%         subbasename = subbasename(1:end-l);
%     end
%    
% end
