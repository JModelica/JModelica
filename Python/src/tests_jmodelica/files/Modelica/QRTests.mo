package QRTests

model QR1
Real A[2,2] = {{1,2},{3,4}};
Real QR[2,2];
Real tau[2];
Integer p[2];
equation 
(QR,tau,p) = Modelica.Math.Matrices.LAPACK.dgeqpf(A);
end QR1;

model QR2
Real A[2,2] = {{1,2},{3,4}};
Real Q[2,2];
Real R[2,2];
Integer p[2];
equation 
(Q,R,p) = Modelica.Math.Matrices.QR(A);
end QR2;

end QRTests;