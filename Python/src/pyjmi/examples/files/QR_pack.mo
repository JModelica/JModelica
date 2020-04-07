package QR_pack

model QR1
  Real A[2,2] = {{1,2},{3,4}};
  Real QR[2,2];
  Real tau[2];
  Integer p[2];
equation 
  (QR,tau,p) = Modelica.Math.Matrices.LAPACK.dgeqpf(A);
end QR1;

end QR_pack;
