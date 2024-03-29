function R = qr_givens (A)
%QR_GIVENS Givens-rotation QR factorization.
% Example:
%   R = qr_givens (A)
% See also: cs_demo

% CSparse, Copyright (c) 2006-2022, Timothy A. Davis. All Rights Reserved.
% SPDX-License-Identifier: LGPL-2.1+

[m n] = size (A) ;
parent = cs_etree (sparse (A), 'col') ;
A = full (A) ;
for i = 2:m
    k = min (find (A (i,:))) ;                                              %#ok
    if (isempty (k))
        continue ;
    end
    while (k > 0 & k <= min (i-1,n))                                        %#ok
        A ([k i],k:n) = givens2 (A(k,k), A(i,k)) * A ([k i],k:n) ;
        A (i,k) = 0 ;
        k = parent (k) ;
    end
end
R = sparse (A) ;
