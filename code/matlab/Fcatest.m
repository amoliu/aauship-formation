clear all; 

%% Formation generation
% Eksempel med to skibe

% Antal skibe i formation
N = 2;
i = 1;%:N;
%j = 1:N;

% Sikkerhedsradius
rsav = 3;

% Virtuel leader pos
vl = [0,0];

% Desired pos af skibe
p0 = [2,2];
%p0(2) = [6,2];

% Pos af skibe
p = [6,4];
%p(2) = [6,6];

% Dists fra skibe til desired givet ud fra vl
d = vl - p;
d0 = vl - p0;
de = d - d0;

% Kraft mellem skib i og vl
Kvl = 20;
Fvl = Kvl*(de);

% % Dist mellem skibe
% d12 = p1 - p2;
% d12_0 = p1_0 - p2_0;
% d12_e = d12 - d12_0;
% 
% % Tiltrækning mellem skib i og j, minimerer imod dij0
Kij = 0.1;
% Fij_12 = Kij*(d0(i,j));
% 
% % Frastødning mellem skibe
Kca = 200;
% for k=1:N
%     if d12(k) < rsav
%         Fca(k) = ( (Kca*rsav)/abs(d12(k))-Kca ) * d12(k)/abs(d12(k));
%     else
%         Fca(k) = 0;
%     end
% end


% % Frastødning mellem skibe og objekter
Koa = 200;
% 
% % Placering af objekt
% po1 = [4,4];
% 
% % Afstande mellem skibe til objekt
% do1 = p1 - po1;
% do2 = p2 - po1;
% 
% for k=1:N
%     if d(k) < rsav
%         F(k) = ( (Koa/abs(d(k)))-Koa/rsav ) * d(k)/abs(d(k));
%     else
%         F(k) = 0;
%     end
% end
% 
% %Fi = Fvl + Fij + Fca + Foa;


%% 3D plot with force magnitude

step = 0.5;
[X,Y] = meshgrid(-20:step:20,-20:step:20);
Ftot = zeros(length(X), length(Y),2);


for m = 1:length(X);
    for n = 1:length(Y);
        p = [X(1,m),Y(n,1)];
        Fvl = Kvl*(vl-p-(vl-p0));
        Fvlmagn(m,n) = norm(Fvl);
        
        pj = [0 , 0];
        dist = p - pj;
        d0ij = p0 - pj;
        Fij = Kij*(dist-d0ij);
        Fijmagn(m,n) = norm(Fij);
        
        if norm(dist) < rsav
            Fca = ((Kca*rsav)/norm(dist)-Kca)*(dist/norm(dist));
        else
            Fca = 0;
        end
        Fcamagn(m,n) = norm(Fca);
        
        po1 = [-3,-3];
        dist = p - po1;
        if norm(dist) < rsav
            Foa = (Koa/norm(dist)-Koa/rsav)*(dist/norm(dist));
        else
            Foa = 0;
        end
        Foamagn(m,n) = norm(Foa);
        
        Ftot = Fvl+Fij+Fca+Foa;
        Ftotmagn(m,n) = norm(Ftot);
    end
end

figure(1)
clf;
hold on
axis equal
[xvel,yvel] = gradient(-Fvlmagn,step,step);
contour(X, Y, Fvlmagn);
quiver(X(1,:),Y(:,1),xvel,yvel);
hold off
figure(2)
clf;
hold on
surf(X, Y, Fvlmagn);
contour(X, Y, Fvlmagn);
hold off
figure(3)
clf;
hold on
surf(X, Y, Fijmagn);
hold off
figure(4)
clf;
surf(X,Y,Fcamagn)
figure(5)
clf;
surf(X,Y,Foamagn)
figure(6)
clf;
surf(X,Y,Ftotmagn);










