function [A]= Gauss(A,b);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%use Gaussian elimination method to change 'A' into upper triangular matrix
% Nov 26,2008
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
A = [A b];
[m,n]=size(A);              %get the size of matrix 'A'
 
% column pivotal elimination method
for k=1:m
   [v,u]=max(abs(A(k:m, k)));    %select the maximum element into the kth 
                                %column of matrix A(k:n,1:k)
   u=u+k-1;        %because function max return the index of maximum values
                   %of A(k:n,1:k) so we should change it into the value of
                   %matrix A
   p(k)=u;         %record the index u
   %exchange the row of k and u
   t1 = A(k,k:n);          %temporary variable t1
   A(k,k:n) = A(u,k:n);
   A(u,k:n) = t1;

   % Gauss elimination method
   cof = A(k, k);
   for iRow = 1 : m
       if iRow ~= k
           iRowA = -A(k, :)/cof*A(iRow, k) + A(iRow, :);
           A(iRow, :) = iRowA;
       end
   end
   A(k, k:n) = A(k, k:n)/cof;
end

