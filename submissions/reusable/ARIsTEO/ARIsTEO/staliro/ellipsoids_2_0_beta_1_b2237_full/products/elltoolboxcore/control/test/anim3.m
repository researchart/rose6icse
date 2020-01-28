% Copyright Claudio Menghi, University of Luxembourg, 2018-2019, claudio.menghi@uni.lu  

  A1 = {'sin(0.3*t)' '-0.22' '0'; '0' '-1' '0'; '-0.5' '1' 'cos(0.2*t)'};
  A2 = [0 0 1; 0 0 0; -4 0 0];
  B1 = [0 1 1; 1 1 0; 1 0 1];
  B2 = [1 0; 0 0; 0 1];
  U1 = ellipsoid([1 0 0; 0 2 0; 0 0 2]);
  U2.center = [0; 0];
  U2.shape = {'2 - sin(2*t)' '0'; '0' '2- cos(3*t)'};
  T  = [0 2];
  L0 = [1 0 0; 0 0 1;0 1 1;1 -1 1; 1 0 1; 1 1 0]';
  X0 = ell_unitball(3);

  s1 = linsys(A1, B1, U1);
  s2 = linsys(A2, B2, U2);
  rs1 = reach(s1, X0, L0, T);
  rs2 = evolve(rs1, 5, s2);
