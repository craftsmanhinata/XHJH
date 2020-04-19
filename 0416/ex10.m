cmat=cumtrue([1,-2],[1,-1.5,0.8],3,25);
clf, subplot(121)
mesh(-25:25,-25:25,cmat), grid on
subplot(122), contour(-25:25,-25:25,cmat,8),grid on