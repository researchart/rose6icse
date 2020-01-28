% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  
 A = {'0' '-2' '0' '0' '0' '0' '0' '0' '0' '0'
      '2' '0'  '0' '0' '0' '0' '0' '0' '0' '0'
      '0' '0'  'cos(t)' '0' '0' '0' '0' '0' '0' '0'
      '0' '0' '0' '0' '0' '0' '1' '0' '0' '0'
      '0' '0' '0' '0' '0' '-1' '0' '0' '0' '0'
      '0' '0' '0' '-1-(sin(2*t))^2' '0' '0' '0' '0' '0' '0'
      '0' '0' '0' '2' '0' '0' '0' '0' '0' '0'
      '0' '0' '0' '0' '0' '0' '0' '-0.5' '0' '0'
      '0' '0' '0' '0' '0' '0' '0' '0' '1+(1/t)' '0'
      '0' '0' '0' '0' '0' '0' '0' '0' '-2' '-1'};

 B = [1 0 0; 0 1 0; 0 0 1; -1 0 1; 0 0 0; 0 0 0; 1 1 1; 0 1 0; 0 0 0; 0 0 0];
 U.center = {'sin(2*t)'; '1+cos(t)'; '-1'};
 U.shape  = [4 -1 0; -1 1 0; 0 0 2];
 X0 = ell_unitball(10) + [4 1 0 7 -3 -2 1 2 0 0]';

 s = linsys(A, B, U);

 T = [1 5];

 L0 = [1 1 -1 0 1 0 0 0 -1 1; 0 1 0 1 0 -1 0 -1 0 1]';
 L0 = eye(10);

 rs = reach(s, X0, L0, T);

 BB = [1 0 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 0; 0 0 0 1 0 0 0 0 0 0]';
 BB = [1 0 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 0]';
 BB = [0 0 0 0 0 0 0 0 0 1; 0 0 1 0 0 0 0 0 0 0]';

 ps=projection(rs, BB);

 plotByEa(ps); hold on; plotByIa(ps);
