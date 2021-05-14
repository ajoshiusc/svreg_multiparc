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



function [nrm,Anrm] = colnorm(A);

[m,n] = size(A);

if(m>1),			% multiple rows
  nrm = sqrt(sum([A.*conj(A)]));
else				% A is row vector
  nrm = abs(A);			% just return mag of each column
end

if(nargout > 1),
  ndx = find(nrm>0);		% any zero norm?
  Anrm = zeros(size(A));
  % normalize any non-zero columns
  Anrm(:,ndx) = A(:,ndx) ./ nrm(ones(m,1),ndx);
end

return
