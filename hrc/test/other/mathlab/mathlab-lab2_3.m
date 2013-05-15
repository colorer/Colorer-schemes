function lab2_3()

M1=[0 1]';
M2=[1 -1]';
M3=[-2 1]';


R1=[0.4 0.1
    0.1 0.4];

R2=[1.0 -0.1
    -0.1 0.2];

R3=[0.2 -0.1
    -0.1 0.4];

X1 = load('x1.dat');
X2 = load('x2.dat');
X3 = load('x3.dat');

plot(X1(1,:),X1(2,:),'*r');
hold on
plot(X2(1,:),X2(2,:),'+b');
plot(X3(1,:),X3(2,:),'.g');

Xc = -1.055;

DrawSeparator( M1, M2, R1, R2, Xc, 3, X1, X2, 1, 2 )
DrawSeparator( M1, M3, R1, R3, -3, Xc, X1, X3, 1, 3 )
DrawSeparator( M3, M2, R3, R2, -3, Xc, X3, X2, 2, 3 )

axis([-3 3 -2.5 3])

hold off

function DrawSeparator( M1, M2, R1, R2, x1, x2, X1, X2, n1, n2 )
  A = R2^(-1) - R1^(-1);
  B = 2 * ( M1' * R1^(-1) - M2' * R2^(-1) );
  c = log( det(R2) / det(R1) ) - M1' * R1^(-1) * M1 + M2' * R2^(-1) * M2;

  x = x1 + [0:20]/20 .* (x2 - x1);

  aX = (A(1,2) + A(2,1)) .* x + B(1,2);
  cX = A(1,1) .* (x .^ 2) + B(1,1) .* x + c(1,1);

  y = (-aX + sqrt( aX.^2 - 4 .* cX .* A(2,2) )) ./ (2 .* A(2,2));

  plot( x, y, 'k' )

  % error probabilities

  ErrF = inline('(sign(x)+1)/2');
  N = length(X1);

  discr = A(1,1) .* X1(1,:).^2 + A(2,2) .* X1(2,:).^2 + (A(1,2) + A(2,1)) .* X1(1,:) .* X1(2,:) + B(1,1) .* X1(1,:) + B(1,2) .* X1(2,:) + c(1,1);
  p1est = sum( 1 - ErrF( discr ) ) / N;
  disp( ['error ' int2str(n1) ' <=>  ' int2str(n2) ' = ' num2str(p1est)] )

  discr = A(1,1) .* X2(1,:).^2 + A(2,2) .* X2(2,:).^2 + (A(1,2) + A(2,1)) .* X2(1,:) .* X2(2,:) + B(1,1) .* X2(1,:) + B(1,2) .* X2(2,:) + c(1,1);
  p2est = sum( ErrF( discr ) ) / N;
  disp( ['error ' int2str(n2) ' <=> ' int2str(n1) ' = ' num2str(p2est)] )

  p2avg = mean([ p1est, p2est ]);
  disp( ['average ' int2str(n1) ' <=> ' int2str(n2) ' = ' num2str(p2avg)] )

  epsilon = 0.05;
  N_eps = round( (1-p2avg)/epsilon^2/p2avg );
  disp( ['N_eps ' int2str(n1) ' <=> ' int2str(n2) ' = ' num2str(N_eps)] )
  