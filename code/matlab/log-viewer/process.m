clear all
for fighandle = findobj('Type','figure')', clf(fighandle), end

%% Data files
logpath = '/afs/ies.auc.dk/group/14gr1034/public_html/tests/';
testname = 'newseatrail';

%% Data files
gps1file = fopen([logpath,testname,'/gps1.log']);
imudata = load([logpath,testname,'/imu.log']);
echofile = fopen([logpath,testname,'/echo.log']);
starttime = imudata(1,13); % Earliest timestamp
annotatefile = fopen([logpath,testname,'/annotate1399289431.26.log'],'r');
% annotatefile = fopen([logpath,testname,'/annotate1400061527.83.log'],'r');
ctlfile = fopen([logpath,testname,'/ctl.log'],'r');

annotate = textscan(annotatefile, '%f%f%s', 'Delimiter', ';');
ctl = textscan(ctlfile, '%f%f%f', 'Delimiter', ',');

%% Reading GPS data
line = textscan(gps1file,'%f,%c,%f,%c,%f,%c,%f,%f');
time = line{1};
nmealat = line{3};
latsign = line{4};
nmealon = line{5};
lonsign = line{6};
nmeaspeed = line{7};
walltime = line{8};

%% Converts the latitude an longitide to decimal coordinates
[pos] = nmea2decimal({nmealat,latsign,nmealon,lonsign});
lat = pos(1,:);
lon = pos(2,:);

% figure(1)
% plot(lon,lat,'.r')
% plot_google_map('maptype','satellite')
% title('WGS84')


%% Tangent plance coordinates xyz (not verified)
% latrad = lat*pi/180;
% lonrad = lon*pi/180;
% hei = gpsdata(:,3);
% N = length(lat);
% hei=zeros(N,1);
% x=zeros(N,1);
% y=zeros(N,1);
% z=zeros(N,1);
% for kk = 1:N
%     %[x(kk) y(kk) z(kk)] = wgs842ecef(latrad(kk),lonrad(kk),0);
%     [x(kk) y(kk) z(kk)] = geodetic2ecef(latrad(kk),lonrad(kk),hei(kk),referenceEllipsoid('wgs84'));
% end
% 
% %% Transform 
% %index = 4;
% %meanlat = latrad(1);
% %meanlon = lonrad(1);
%  meanlat = 57.015179789287792*pi/180;
%  meanlon = 9.985062449450744*pi/180;
% meanhei = hei(1);
% % [a b c]=wgs842ecef(meanlat,meanlon,meanhei);
% [a b c]=geodetic2ecef(meanlat,meanlon,meanhei,referenceEllipsoid('wgs84'));
% % plot3(a,b,c,'r*')
% R_e2t = [-sin(meanlat)*cos(meanlon) -sin(meanlat)*sin(meanlon) cos(meanlat);...
%     -sin(meanlon) cos(meanlon) 0;...
%     -cos(meanlat)*cos(meanlon) -cos(meanlat)*sin(meanlon) -sin(meanlat)];
% 
% T = zeros(3,N);
% for kk = 1:N
%     T(:,kk) = R_e2t*([x(kk);y(kk);z(kk)]-[a;b;c]);
% end
% T = T';
% 
% figure(1)
% % T(300:360,:) = 0
% plot(T(:,2),T(:,1))
% title('Raw GPS log (localframe)')


%% ADIS16405 Inertial Measurement Unit
supply = imudata(:,1)*0.002418; % Scale 2.418 mV
gyro = imudata(:,2:4)*0.05; % Scale 0.05 degrees/sec
accl = (imudata(:,5:7)*0.00333)*9.82;   %/333)*9.82; % Scale 3.33 mg (g is gravity, that is g-force)
magn = imudata(:,8:10)*0.0005; % 0.5 mgauss
temp = imudata(:,11)*0.14; % 0.14 degrees celcius 
aux_adc = imudata(:,12)*0.806; % 0.mV180/pi
imutime = imudata(:,13)-starttime; % Seconds since start, periodic timing determined by imu

% figure(2)
% subplot(4,1,1)
% plot(imutime, gyro)
% title('Gyrometer')
% ylabel('[degrees/sec]')
% legend('X','Y','Z')
% 
% subplot(4,1,2)
% plot(imutime, accl)
% title('Accelerometer')
% ylabel('[m/s^2]')
% 
% subplot(4,1,3)
% plot(imutime, magn)
% title('Magnetometer')
% ylabel('[gauss]')
% 
% subplot(4,1,4)
% plot(imutime, imudata(:,[1 11:12]))
% title('Supply, temperature and ADC of the ADIS16405 IMU')
% ylabel('[V, degC, V]')
% xlabel('Time [s]')
% legend('Supply','Temp','ADC')

%% Heading
% X_H = X*cos(pitch) + Y*sin(roll)*sin(pitch) - Z*cos(roll)*sin(pitch)
% Y_H = Y*cos(roll) + Z*sin(roll)
% Azimuth = atan2 (Y_H / X_H )

heading = atan2(-magn(:,2),magn(:,1))*180/pi;
% figure(3)
% % subplot(2,1,1)
% 
% % plot(imutime,smooth(heading,15, 'rloess'),'-')
% plot(imutime,heading,'-')
% title('Heading calculated with atan2, not corrected for pitch or roll')
% % subplot(2,1,1)
% plot(imutime,Azimuth)

figure(50)
bias = [0.2582 0.1225 -0.6860];
% bias = [(max(magn(:,1))-min(magn(:,1)))/2+min(magn(:,1)),...
%         (max(magn(:,2))-min(magn(:,2)))/2+min(magn(:,2)),...
%         (max(magn(:,3))-min(magn(:,3)))/2+min(magn(:,3))]
plot3(magn(:,1)-bias(1),magn(:,2)-bias(2),magn(:,3)-bias(3))
xlabel('x');ylabel('y');zlabel('z');
axis equal
grid on
% hold on
% plot3(bias(1), bias(2), bias(3),'r*')
% hold off


%% MEMSENS stuff
magnbias = [magn(:,1)-bias(1) magn(:,2)-bias(2) magn(:,3)-bias(3)];
imu2beh(gyro, accl/9.82, magnbias, length(gyro));
% imu2beh([gyro(:,1) -gyro(:,2) -gyro(:,3)], [accl(:,1) -accl(:,2) -accl(:,3)], [magn(:,1) -magn(:,2) -magn(:,3)], length(gyro));
beh = calc_beh_main('testfile.mat',false,true,true,false);

%% Animate heading
%     figure(42)
% 
% clf
% for ii = 1:length(heading)
%     figure(42)
%     polar([heading(ii)*pi/180,0],[2,0],'-')
%     title(num2str(imutime(ii,1)))
%     pause(0.03)
% end
% hold off


%% Echosounder data
echo.depth.value=NaN;
echo.depth.timestamp=NaN;
echo.temperature.value=NaN;
echo.temperature.timestamp=NaN;

ii=1;

filenotdone = 1;
while(filenotdone > 0)
    % scan single line into matrix
    [str, count] = fscanf(echofile, '%[^\n]', 1);
    % skip over \n
    [strnl, count] = fscanf(echofile, '%[\n]', 1);
    % make sure we stop the while when EOF
    if(count == 0)
        filenotdone = 0;
    end
    
    delim = findstr(',',str);
    % detph data
    if isempty(findstr(str,'$SDDPT,'))~=1
        ii=ii+1;
        s = sscanf(str(delim(1)+1:delim(2)-1), '%f');
        ss = sscanf(str(delim(3)+1:length(str)), '%f');
        if(s)
            echo.depth.value(ii) = s;
            echo.depth.timestamp(ii) = ss;
        else
            echo.depth.value(ii) = NaN;
            echo.depth.timestamp(ii) = NaN;
        end
    end
    
    % temperature data
    if isempty(findstr(str,'$SDMTW,'))~=1
        s = sscanf(str(delim(1)+1:delim(2)-1), '%f');
        ss = sscanf(str(delim(3)+1:length(str)), '%f');
        if(s)
            echo.temperature.value(ii) = s;
            echo.temperature.timestamp(ii) = ss;
        else
            echo.temperature.value(ii) = NaN;
            echo.temperature.timestamp(ii) = NaN;
        end
    end
    
end
figure(4)
plot(echo.depth.timestamp,echo.depth.value,echo.temperature.timestamp',echo.temperature.value)
xlabel('Timestamp [s]')
ylabel('Depth [m] / Temperature [degree C]')
legend('Depth','Temperature')


%% 
%figure(100)
clf
scale_imutime = 0.8305;
offset_imutime = 205;
hold on
plot(ctl{3}-starttime, ctl{2},'.-',...
     imutime*scale_imutime+offset_imutime,accl(:,1)*100,...
     imutime*scale_imutime+offset_imutime,accl(:,2)*100,...
     imutime*scale_imutime+offset_imutime,accl(:,3)*100,...
     (walltime-starttime)*scale_imutime+offset_imutime,nmeaspeed*100,'.-k',...
     imutime*scale_imutime+offset_imutime,beh.heading)
 plot((walltime(1057)-starttime)*scale_imutime+offset_imutime,nmeaspeed(1057)*100,'r*')

% plot(ctl{3}-starttime, ctl{2}, imutime*0.865,heading(:,1),'.-k')

legend('control inputs',...
      'accx', 'accy', 'accz',...
      'gps1 speed')
%  ylim([-500 500])
diffad=annotate{1}(1)-starttime-1870;
annotatefill(annotate{1}-diffad-starttime,annotate{2}-diffad-starttime,annotate{3},-150,150)
hold off
xlabel('Time [s]')
ylabel('Control inputs, not sorted by MsgID [-]')

%%
% Plotting speeds from nmeaspeed
% Timediff from nmeasspeed to sample = 828
% figure(42)

% Determine X_u
m = 13;
clf;
surge1 = nmeaspeed(1881-828+2:1901-828+2)*0.5144;
surge2 = nmeaspeed(1916-828+1:1933-828+1)*0.5144;
surge3 = nmeaspeed(1961-828:1975-828)*0.5144;
surge4 = nmeaspeed(2022-828-3:2035-828-3)*0.5144;
surge5 = nmeaspeed(2112-828-5:2126-828-5)*0.5144;
surge6 = nmeaspeed(2205-828-5:2212-828-5)*0.5144;
hold on
grid on
x = 0:27;
plot(-3:(length(surge1)-4),surge1,'r');
plot(-3:(length(surge2)-4),surge2,'g');
plot(-3:(length(surge3)-4),surge3,'y');
plot(-3:(length(surge4)-4),surge4,'b');
plot(-3:(length(surge5)-4),surge5,'k');
plot(-3:(length(surge6)-4),surge6,'c');
k = 3.3*0.5144;
s = 0.22;
plot(x,k*exp(-s*x),'p')
hold off
D = s * m;
X_u = D

% Determine noget andet




























