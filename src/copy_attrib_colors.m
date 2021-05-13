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


function copy_attrib_colors(sub_base,hemi,ext)

if ~exist('ext','var')
    ext='svreg.dfs';
end


if ~exist('hemi','var')
    
    sr=readdfs([sub_base,'.left.mid.cortex.',ext]);
    %st=sr;
    
    if exist([sub_base,'.left.pial.cortex.dfs'],'file')
        si=readdfs([sub_base,'.left.inner.cortex.dfs']);
        st=sr;st.vertices=si.vertices;
        writedfs([sub_base,'.left.inner.cortex.',ext],st);
        
        si=readdfs([sub_base,'.left.pial.cortex.dfs']);
        st=sr;st.vertices=si.vertices;
        writedfs([sub_base,'.left.pial.cortex.',ext],st);
    end
    
    sr=readdfs([sub_base,'.right.mid.cortex.',ext]);
    
    if exist([sub_base,'.right.pial.cortex.dfs'],'file')
        
        si=readdfs([sub_base,'.right.inner.cortex.dfs']);
        st=sr;st.vertices=si.vertices;
        writedfs([sub_base,'.right.inner.cortex.',ext],st);
                
        si=readdfs([sub_base,'.right.pial.cortex.dfs']);
        st=sr;st.vertices=si.vertices;
        writedfs([sub_base,'.right.pial.cortex.',ext],st);
        
    end
else
    sr=readdfs([sub_base,'.',hemi,'.mid.cortex.',ext]);
    %st=sr;
    
    if exist([sub_base,'.',hemi,'.pial.cortex.dfs'],'file')
        si=readdfs([sub_base,'.',hemi,'.inner.cortex.dfs']);
        st=sr;st.vertices=si.vertices;
        writedfs([sub_base,'.',hemi,'.inner.cortex.',ext],st);
        
        si=readdfs([sub_base,'.',hemi,'.pial.cortex.dfs']);
        st=sr;st.vertices=si.vertices;
        writedfs([sub_base,'.',hemi,'.pial.cortex.',ext],st);
    end
end

