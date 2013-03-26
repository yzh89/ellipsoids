E = ellipsoid([-2; -1], [4 -1; -1 1]);
B = ell_unitball(2);
E1 = [E B E.inv];
L = [1 0; 1 1; 0 1; -1 1]';
EA = E1.minksum_ea(L)

% EA =
% 1x4 array of ellipsoids.