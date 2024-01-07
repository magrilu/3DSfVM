function [ output_args ] = drawCircle( x,y,r,col)
%DRAWCIRCLE draw a circle of given center (x,y) and radius r
if(nargin <4)
    col = 'k-.';
end

t=[0:0.1:2*pi];
X=x+r*cos(t);
Y=y+r*sin(t);
plot(X,Y,col);
axis equal

end

