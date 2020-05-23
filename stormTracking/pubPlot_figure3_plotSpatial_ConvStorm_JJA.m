% ----------------------------------------------------------------------- %
% THIS SCRIPT IS TO VISUALIZE SEVERAL STATISTICS FOR CONVECTIVE STROM DURING
% SUMMERTIME
%
% ... # some necessary description # ...
%
% # Spatial Characteristics
% Here storms with PMax were identified, and then density center were
% identified for plotting
%
% # Smoothing
% Convolution was used in several steps to locate the Pmax. But of course
% on the final images showing the averaged pattern, we are using the raw
% simulation output from CPM.
%
%
%
% @ Yuting Chen
% Imperial College London
% yuting.chen17@imperial.ac.uk
% ----------------------------------------------------------------------- %
clear;clc;

% Several Config
close all
setFigureProperty('Subplot2');
global regionName savePath region
ENSEMBLENO = getEnsNos();
durThre = [];% 6;

Num = 40;%
for regionName = {'WAL','SCO','EUK'}% 

    regionName = regionName{1};
    region = getfield(REGIONS_info(),regionName);
    
    x_name = 'rpmax';%'rspeed';%'rsize';%
    savePath = 'C:\Users\Yuting Chen\Dropbox (Personal)\Data_PP\Fig_UKCP\StormTracking';
    
    PERIODS = {'1980-2000','2060-2080'}; % {'2007-2018'};% ;'2020-2040',
    RAs = [];
    
    % Get data (opt: plot)
    pi = 1;
    for Period = PERIODS
        
        Period = Period{1};
        %{
        Ra = [];
        for ensNo = ENSEMBLENO([1:12])
            ensNo = ensNo{1};
            [STATS0,T0] = get4Plot(Period,ensNo,Num,durThre);
            Ra0 = plot_40CS(STATS0,T0,Period,durThre,ensNo);
            Ra = cat(3,Ra,Ra0);
            close all
        end
        Config = getConfig(upper(regionName),6,Period,ensNo);
        save(sprintf('%s%sCS_%s_%s_4PubPlot_%03dStorms.mat',Config.saveIt.path,...
            filesep,regionName,Period,Num*12),'Ra');
        %}
        ensNo = '15';
        Config = getConfig(upper(regionName),6,Period,ensNo);
        load(sprintf('%s%sCS_%s_%s_4PubPlot_%03dStorms.mat',Config.saveIt.path,...
            filesep,regionName,Period,Num*12),'Ra');
        plot_averageRa(Ra,Period,ENSEMBLENO,durThre);
        
        RAs{pi} = Ra;
        pi = pi+1;
    end
    
    close all
    
    
    
    %% test %% plot Precipitation Reduction
    figure;
    hold on;
    x = 2.2*(-25:25);
    y = 2.2*(-25:25);
    [XX,YY] = meshgrid(x,y);
    RD = sqrt(XX.^2+YY.^2);
    hand = [];
    Ra_ens = reshape(RAs{1},[size(RAs{1},[1,2]),size(RAs{1},[3])/12,12]);
    DAT = squeeze(nanmean(nanmean(Ra_ens,4),3));
    [hand(1),xi_1,yi_1,Mfit_1] = plotReduction(DAT,RD,RAs{1},getColor(PERIODS{1}));
    
    Ra_ens = reshape(RAs{2},[size(RAs{2},[1,2]),size(RAs{2},[3])/12,12]);
    DAT = squeeze(nanmean(nanmean(Ra_ens,4),3));
    [hand(2),xi_2,yi_2,Mfit_2] = plotReduction(DAT,RD,RAs{2},getColor(PERIODS{2}));

    ylim([0,1.1]);%%%%
    xlim([100,5000])
    set(gca,'YScale','log')
    set(gca,'XScale','log')
    1;
    %% Output Plot %%
    % plot Radial averaged precipitation
    figure;
    hold on;
    x = 2.2*(-25:25);
    y = 2.2*(-25:25);
    [XX,YY] = meshgrid(x,y);
    RD = sqrt(XX.^2+YY.^2);
    hand = [];
    Ra_ens = reshape(RAs{1},[size(RAs{1},[1,2]),size(RAs{1},[3])/12,12]);
    DAT = squeeze(nanmean(nanmean(Ra_ens,4),3));
    % DAT = squeeze((nanmedian(Ra_ens,3)));
    [hand(1),xi_1,yi_1,Mfit_1] = plotOneRadialP(DAT,RD,RAs{1},getColor(PERIODS{1}));
    Ra_ens = reshape(RAs{2},[size(RAs{2},[1,2]),size(RAs{2},[3])/12,12]);
    DAT = squeeze(nanmean(nanmean(Ra_ens,4),3));
    % DAT = squeeze((nanmedian(Ra_ens,3)));
    [hand(2),xi_2,yi_2,Mfit_2] = plotOneRadialP(DAT,RD,RAs{2},getColor(PERIODS{2}));
    % DAT = squeeze(nanmedian(RAs{3},3));
    % hand(3) = plotOneRadialP(DAT,RD,RAs{3},'k');
    
    % set(gca,'XScale','log');%%%%
    % ylim([0,1.1]);%%%%
    
    
    Mfit_1
    Mfit_2
    yyaxis right
    plot(xi_1,100*(yi_2-yi_1)./yi_1,'-','Color',ones(1,3)*0.7);
    ax = gca;
    ylim([-10,90]);
    ax.YColor = ones(1,3)*0.4;
    ylabel('PR Difference [%]')
    yyaxis left
    legend(hand,PERIODS);
    % xlim([0,40]);ylim([0,60])
    xlim([0,35]);ylim([0,85])
    xlabel('Radial distance from system centre (km)');
    ylabel('Mean Precipitation (mm h^{-1})');
    set(gca,'TickDir','out');
    saveName = sprintf('%s-MeanP_RadialR-%s-Thre%02dh',regionName,ensNo,durThre);
    savePlot([savePath,filesep,saveName],'XYWH',[150,0,300,250],'needreply','N','onlyPng',true);
    
    close all
    
    %%
    
    % plot Intensity-Area Curve
    figure;
    hold on;
    
    DAT = squeeze(nanmean(RAs{1},3));
    hand(1) = plotOneIntArea(DAT,RD,RAs{1},getColor(PERIODS{1}));
    DAT = squeeze(nanmean(RAs{2},3));
    hand(2) = plotOneIntArea(DAT,RD,RAs{2},getColor(PERIODS{2}));
    % DAT = squeeze(nanmean(RAs{3},3));
    % hand(3) = plotOneIntArea(DAT,RD,RAs{3},'k');
    legend(hand,PERIODS);
    xlim([0.1,60])
    ylim([0.1,10^5])
    set(gca,'YScale','log')
    grid minor
    ylabel('Precipitation Area Covered (Km^2)');
    xlabel('Precipitation (mm h^{-1})');
    set(gca,'TickDir','out');
    saveName = sprintf('%s-Intensity_Area-%s-Thre%02dh',regionName,ensNo,durThre);
    savePlot([savePath,filesep,saveName],'XYWH',[150,0,300,250],'needreply','N','onlyPng',true);
    
    
end

% AUXILLARY FUNCTION
function Col = getColor(period)
switch(period)
    case '1980-2000'
        Col = [66 146 199]/255;
    case '2060-2080'
        Col = [240  60  43]/255;
end
end
function hand=plotOneIntArea(DAT,RD,RA,colo);
% DAT0 = DAT(:);
% RD0 = floor(RD(:));
% T = table(DAT0,RD0);

RD0 = repmat(reshape(RD,[size(RD),1]),[1,1,size(RA,3)]);
RD0 = RD0(:);
DAT0 = RA(:);
T = table(DAT0,RD0);
A = grpstats(T,'RD0',{'median',@(x)quantile(x,.75),@(x)quantile(x,.25)});
xi = A.RD0;

try
% % #fit version#
% xx = xi;
% yy = A.median_DAT0;
% ft = fittype('pm*exp(-x/k)+d');
% Mfit = fit(xx,yy,ft,'StartPoint',[nanmax(yy)+0.1,9,0.06]);
% k = Mfit.k;
% d = Mfit.d;
% pmax = Mfit.pm;
% ci = confint(Mfit,0.95);
% rr = linspace(0.1,nanmax(xi),200);
% xx = pmax.*exp(-rr./k)+d;
% yy = 2*pi*(rr).^2;
% hand = plot(xx,yy,'-','color',colo);

% #no-fit version#
% xx = A.mean_DAT0;
% yy = 2*pi*(xi+0.5).^2;
hand = plot(A.median_DAT0,0.1+2*pi*(xi).^2,'--','color',colo);
catch me
    % #no-fit version#
    % xx = A.mean_DAT0;
    % yy = 2*pi*(xi+0.5).^2;
    hand = plot(A.median_DAT0,0.1+2*pi*(xi).^2,'--','color',colo);
end
hsimran = fill([A.Fun3_DAT0;flip(A.Fun2_DAT0)],0.1+2*pi.*([xi;flip(xi)]).^2,colo,...
    'LineStyle','none');
alpha(0.3)
end

function Ra = plot_40CS(STATS0,T0,Period,durThre,ensNo)

global regionName savePath region
figure;
Ra = zeros(51,51,0);

for i = 1:length(STATS0)
    R = STATS0{i};
    thisTime = T0{i};
    
    % # system centre #
    % # opt 1 #
    % R_temp = conv2(R,ones(3,3)/9,'same');
    % [maxi,maxj] = find(R_temp==nanmax(R_temp(:)),1);
    % fprintf('%3dmm/h\n',nanmax(R_temp(:)));
    
    % # opt 2 # #seems better#
    % This one gives us the weighted centroid for area having highest Pmax.

    R_temp = R*0; 
    R_temp([1+25:size(R,1)-25],[1+25:size(R,2)-25]) = R([1+25:size(R,1)-25],[1+25:size(R,2)-25]);

    % pick up heaviest point.
    surVec = [1,1,1;1,0,1;1,1,1];
    R_temp(R_temp<5) = 0;
    surB5 = conv2(R_temp,surVec,'same');% have at least one surronding bigger than 5mm/h
    R_temp(surB5<1) = 0; % ensure at least 2 grids > 5mm/h
    allVec = [1,1,1;1,2,1;1,1,1];%%%%%%%%%%%%%%%0515Final
    R_temp = conv2(R_temp,allVec/10,'same');%%%%%%%%%%%%%%%%%%%%%%0515Final
    [maxi,maxj] = find(R_temp==nanmax(R_temp(:)),1);
    % R_temp(R_temp<floor(nanmax(R_temp(:)))) = 0;
    % stats = regionprops('table',logical(R_temp),(R_temp),'WeightedCentroid','Area','MaxIntensity');
    
    
    % system centroid
    % R_temp(R_temp<5) = 0;
    % stats = regionprops('table',logical(R_temp),(R_temp),'WeightedCentroid','Area','MaxIntensity');
    % stats(stats.Area==1,:) = [];
    % maxi = round(stats.WeightedCentroid(stats.MaxIntensity == max(stats.MaxIntensity),2));
    % maxj = round(stats.WeightedCentroid(stats.MaxIntensity == max(stats.MaxIntensity),1));
    R(R==0) = NaN;

    R = squeeze(R([max(maxi-25,1):min(size(R,1),maxi+25)],...
        [max(1,maxj-25):min(size(R,2),maxj+25)]));
    
    if ~any(~(size(R)==[51,51]))
        R(isnan(R))=0;[maxi,maxj] = deal(26);
        Ra = cat(3,Ra,R);
    else
        % # In some rare case #.
        % centroid point might be very close to boundary of area.
        % In this case, current setting is to enlarge area and then search
        % for the complete image pattern again.
        elNo = 20;
        if strcmp(region.Name,'bigEUK')
            elNo = 5;
        end
        imageNo = (thisTime.Day-1)*24+thisTime.Hour+1;
        [A,~,~] = readCPM_nc_1_wider(region,thisTime.Year,thisTime.Month,ensNo,imageNo,elNo);
        A(A<1/32)=0;
        R = A;
        maxi = maxi+elNo;
        maxj = maxj+elNo;
        R(R==0) = NaN;
        R = squeeze(R([max(maxi-25,1):min(size(R,1),maxi+25)],...
            [max(1,maxj-25):min(size(R,2),maxj+25)]));
        % R = R*100;
        if any(~(size(R)==[51,51]))
            1;
            continue;
        else
            R(isnan(R))=0;
            Ra = cat(3,Ra,R);
        end
    end
    if ~any(~(size(R)==[51,51]))
        subplot(5,8,i);hold on;
        R(R==0)=NaN; pcolor(1:51,1:51,R);
        % [maxi,maxj] = find(R == nanmax(R(:)));
        maxj = 26;maxi = 26;
        % plot(maxj,maxi,'r+','linewidth',2);
        % xlim(maxj+[-50,50]);
        % ylim(maxi+[-50,50]);
        shading flat;box on;
        cptcmap('cw1-013','mapping','scaled','ncol',100,'flip',true);
        caxis([0,30]);
        thisTime.Format='dd-MMM-uuuu HH:mm';
        title([string(thisTime),sprintf('%04.1d',R(26,26))],'fontsize',8);
        ax = gca;ax.XTick = [];ax.YTick = [];
    end
end

% c = colorbar(gca);
c = colorbar('location','Manual', 'position', [0.92 0.1 0.015 0.8]);
c.Ticks = 0:10:50;
c.TickLabels = strcat(c.TickLabels,'mm/h');
saveName = sprintf('%s-40CSs-highPMax_%s_%s-Thre%02d',regionName,Period,ensNo,durThre);
savePlot([savePath,filesep,saveName],'XYWH',[150,0,910,550],'needreply','N','onlyPng',true);
end

function [hand,xi,yi,Mfit] = plotReduction(DAT,RD,RA,colo);

[Mfit] = deal(NaN);
imN = 5;
RA = imresize3(RA,'scale',[imN,imN,1],'method','box');
x0 = 2.2*linspace(-25,25,51*imN);
y0 = 2.2*linspace(-25,25,51*imN);
[XX,YY] = meshgrid(x0,y0);
RD = sqrt(XX.^2+YY.^2);

RA0 = reshape(RA,[size(RA,[1,2]),size(RA,3)/12,12]);
RD0 = repmat(reshape(RD,[size(RD),1]),[1,1,size(RA0,[3,4])]);
ensNo = repmat(reshape(1:12,[1,1,1,12]),[size(RA0,[1:3]),1]);
RD0 = round(RD0(:));
DAT0 = RA0(:);
ensNo = ensNo(:);
T = table(DAT0,RD0,ensNo);

A = grpstats(T,{'RD0','ensNo'},{'mean',@(x)quantile(x,.75),@(x)quantile(x,.25)});
RD0 = A.RD0;
DAT0 = A.mean_DAT0;
ensNo = A.ensNo;

T = table(DAT0,RD0,ensNo);
A = grpstats(T,{'RD0'},{'median',@(x)quantile(x,1),@(x)quantile(x,0)});
xi = A.RD0;
yi = A.median_DAT0./nanmax(A.median_DAT0);
hand = plot(pi*xi.^2,yi,'-','color',colo);
hsimran = fill([pi*xi.^2;flip(pi*xi.^2)],[A.Fun3_DAT0;flip(A.Fun2_DAT0)],colo,...
    'LineStyle','none');

xx = xi;
yy = A.median_DAT0;
ft = fittype('pm*exp(-x/k)+d');
Mfit = fit(xx,yy,ft,'StartPoint',[nanmax(yy)+0.1,9,0.06],'Exclude', xx > 100);
k = Mfit.k;
d = Mfit.d;
pmax = Mfit.pm;
ci = confint(Mfit,0.95);
xx = linspace(nanmin(xx),nanmax(xx),100);
yy = pmax.*exp(-xx./k)+d;
hold on
hand = plot(pi*xx.^2,yy,'--','color',colo);

alpha(0.3)
end


function [hand,xi,yi,Mfit] = plotOneRadialP(DAT,RD,RA,colo);

% DAT0 = DAT(:);
% RD0 = floor(RD(:));
% T = table(DAT0,RD0);
[Mfit] = deal(NaN);
imN = 5;
RA = imresize3(RA,'scale',[imN,imN,1],'method','box');
x0 = 2.2*linspace(-25,25,51*imN);
y0 = 2.2*linspace(-25,25,51*imN);
[XX,YY] = meshgrid(x0,y0);
RD = sqrt(XX.^2+YY.^2);

RA0 = reshape(RA,[size(RA,[1,2]),size(RA,3)/12,12]);
RD0 = repmat(reshape(RD,[size(RD),1]),[1,1,size(RA0,[3,4])]);
ensNo = repmat(reshape(1:12,[1,1,1,12]),[size(RA0,[1:3]),1]);
RD0 = round(RD0(:));
DAT0 = RA0(:);
ensNo = ensNo(:);
T = table(DAT0,RD0,ensNo);

A = grpstats(T,{'RD0','ensNo'},{'mean',@(x)quantile(x,.75),@(x)quantile(x,.25)});
RD0 = A.RD0;
DAT0 = A.mean_DAT0;
ensNo = A.ensNo;

T = table(DAT0,RD0,ensNo);
A = grpstats(T,{'RD0'},{'median',@(x)quantile(x,1),@(x)quantile(x,0)});
xi = A.RD0;
yi = A.median_DAT0;
hand = plot(xi,yi,'-','color',colo);
hsimran = fill([xi;flip(xi)],[A.Fun3_DAT0;flip(A.Fun2_DAT0)],colo,...
    'LineStyle','none');
try
xx = xi;
yy = A.median_DAT0;
ft = fittype('pm*exp(-x/k)+d');
Mfit = fit(xx,yy,ft,'StartPoint',[nanmax(yy)+0.1,9,0.06],'Exclude', xx > 100);
k = Mfit.k;
d = Mfit.d;
pmax = Mfit.pm;
ci = confint(Mfit,0.95);
xx = linspace(nanmin(xx),nanmax(xx),100);
yy = pmax.*exp(-xx./k)+d;
hold on
hand = plot(xx,yy,'--','color',colo);
%     hand = plot(xi,yi,'-','color',colo);
catch me
%     hand = plot(xi,yi,'-','color',colo);
end
% hsimran = fill([xi;flip(xi)],[A.Fun3_DAT0;flip(A.Fun2_DAT0)],colo,...
%     'LineStyle','none');
alpha(0.3)
end

function plot_averageRa(Ra,Period,ENSEMBLENO,durThre)
global regionName savePath ensNo
fprintf('%02d snapshots were used\n',size(Ra,3));
figure;
numRa = size(Ra,3);
% Ra = reshape(Ra,[size(Ra,[1,2]),size(Ra,3)/12,12]);
% Ra = squeeze(nanmean(nanmean(Ra,3),4));
% scaleN = 22;
% Ra = imresize3(Ra,'scale',[scaleN,scaleN,1],'method','linear');
% Ra = nanmedian(Ra,3);
Ra = reshape(Ra,[size(Ra,[1,2]),size(Ra,3)/12,12]);
Ra = squeeze(nanmean(nanmean(Ra,3),4));

Ra = Ra(11:41,11:41);%%%%%%%%%%%
scaleN = 22;
Ra = -0.1+exp(imresize(log(Ra+0.1),scaleN,'lanczos2'));
% Ra = -0.1+exp(imresize(log(Ra+0.1),scaleN,'box'));
% Ra = imresize(Ra,scaleN,'bilinear');
x = ((1:size(Ra,1))-(size(Ra,1)+1)/2)*2.2/scaleN;
y = ((1:size(Ra,2))-(size(Ra,1)+1)/2)*2.2/scaleN;
hold on;
Ra_temp = Ra;
% Ra_temp(Ra_temp<1) = NaN;%%%%%%%% 
pcolor(x,y,Ra_temp);
[C,h] = contour(x,y,Ra,[5,10,20],'Color',[0.1 0.1 0.1],'Linewidth',1,'Linestyle','-');
clabel(C,h)
shading flat
cptcmap('cw1-013','mapping','scaled','ncol',32,'flip',true);
caxis([0,80])
grid on;
heavyCov = nansum(Ra_temp(:))*10^-3/3600*100*100;
c = colorbar;
c.Ticks = [1,20,40,60,80];c.TickLength = 0.02;
c.TickLabels = strcat(c.TickLabels,'mm/h');
% plot(size(Ra,1)/2+1,size(Ra,2)/2+1,'r+')
% set(gca,'TickDir','out');

xlabel('Distance from Centre /km');
ylabel('Distance from Centre /km');
ax = gca;hold on;
plot(mean(ax.XLim)*ones(2,1),ax.YLim,'k:','linewidth',0.5);
plot(ax.XLim,mean(ax.YLim)*ones(2,1),'k:','linewidth',0.5);
text(ax.XLim(2),ax.YLim(2),sprintf('%4.1fm^3 s^{-1}',heavyCov),...
    'horizontalalignment','right',...
    'verticalalignment','top','fontsize',12);
% plot(20*ones(2,1),ax.YLim,'k:','Color',[0.1 0.1 0.1],'linewidth',0.5);
% plot(-20*ones(2,1),ax.YLim,'k:','Color',[0.1 0.1 0.1],'linewidth',0.5);
% plot(ax.XLim,-20*ones(2,1),'k:','Color',[0.1 0.1 0.1],'linewidth',0.5);
% plot(ax.XLim,20*ones(2,1),'k:','Color',[0.1 0.1 0.1],'linewidth',0.5);
ax.YTick = [-50,-20,0,20,50];
ax.XTick = [-50,-20,0,20,50];
hold off;
box on

axis equal

if iscell(ENSEMBLENO) && length(ENSEMBLENO)>1
    saveName = sprintf('%s-%03dCSs-averaged_%s_%s-%s-Thre%03d',regionName,numRa,Period,...
        ENSEMBLENO{1},ENSEMBLENO{end},durThre);
else
    saveName = sprintf('%s-%03dCSs-averaged_%s_%s-Thre%03d',regionName,numRa,Period,...
        ensNo,durThre);
end
savePlot([savePath,filesep,saveName],'XYWH',[150,0,350,250],'needreply','N',...
    'onlyPng',true);
end


function [Rain,scaleF,region] = readCPM_nc_1_wider(region,year,mon,ensNo,imageNo,elNo);

fileName = sprintf('pr_rcp85_land-cpm_uk_2.2km_%s_1hr_%04d%02d01-%04d%02d30.nc',...
    ensNo,year,mon,year,mon);
try
    filePath = ['K:/UkCp18/',ensNo,'/'];
    listaRain = [filePath,fileName];
    A = ncinfo(listaRain);
catch
    filePath = ['K:/UkCp18_FutureTemp/',ensNo,'/'];
    listaRain = [filePath,fileName];
    A = ncinfo(listaRain);
end

LAT=ncread(listaRain,'latitude');
LON=ncread(listaRain,'longitude');
[E, N] = ll2os(LAT, LON);
E = E/1000;
N = N/1000;
[region.i,region.j] = getRegionIJ(E,N,region.minE,region.minN);

Rain = squeeze(ncread(listaRain,'pr',...
    [region.i-elNo,region.j-elNo  imageNo,  1],...
    [region.dimE+elNo*2,region.dimN+elNo*2    1,  1]));

scaleF = 1;
end


function [A,T] = get4Plot(Period,ensNo,Num,durThre)

global regionName
[RE,TE] = deal([]);
% for MON = 6:8
%     Config = getConfig(upper(regionName),MON,Period,ensNo);
%     Dat = load([Config.saveIt.path,filesep,sprintf('CS_%s_%s_FIELD_%02d_%s.mat',regionName,Period,Config.Month,ensNo)],...
%         'RE','TE','Config');
%     RE = cat(1,RE,Dat.RE);
%     TE = cat(1,TE,Dat.TE);
%     % STATS = [STATS;Dat.RE];
% end

Config = getConfig(upper(regionName),6,Period,ensNo);
Dat = load([Config.saveIt.path,filesep,sprintf('CS_%s_%s_FIELD_%02d-%02d_%s.mat',regionName,Period,6,8,ensNo)],...
    'RE','TE','Config');
RE = Dat.RE;
TE = Dat.TE;
len = cell2mat(cellfun(@(a)size(a,3),RE,'UniformOutput', false));
if ~isempty(durThre)
RE = RE(len>durThre);
TE = TE(len>durThre);
end
% STATS = [STATS;Dat.RE];

% only search for the max value for central part
STATS_rpmax = cell2mat(cellfun(@(a)nanmax(reshape(a(1+25:size(RE{1},1)-25,1+25:size(RE{1},2)-25,:),...
    1,[])),...
    RE,'UniformOutput', false));
[~,I] = sort(STATS_rpmax,'descend');
A = RE(I(1:Num));
STATS_rpmax(I(1:Num));
T = TE(I(1:Num));

[A,T] = cellfun(@(a,t)findRep(a,t,[1+25:size(RE{1},1)-25],[1+25:size(RE{1},2)-25]),A,T,'UniformOutput', false);

    function [A,T] = findRep(As,Ts,Rii,Rjj)
        
        % # Opt 1 #
        % We will take the one with biggest coverage of wet as the
        % representaed images of this events.
        % war = nanmean(reshape(As,[prod(size(As,[1,2])),size(As,3)])>1,1);
        % maxi = find(war == nanmax(war));
        % A = squeeze(As(:,:,maxi));
        % T = Ts(maxi);
        %
        % # Opt 2 #
        % Here a 3*3 convolution was used to smooth spatial
        % field, and then one image having highest Pmax was picked up.
        
        % # Opt 3 #
        As0 = As(Rii,Rjj,:);
        
        surVec = [1,1,1;1,0,1;1,1,1];
        allVec = [1,1,1;1,2,1;1,1,1];
        for i = 1:size(As0,3)
            atemp = squeeze(As0(:,:,i));% 
            % atemp = conv2(squeeze(As0(:,:,i)),ones(3,3)/9,'same');
            % As0(:,:,i) = atemp;
            
            % exclude the case: only one single point as pmax but all
            % surrondings are smaller than 5 mm/h.
            atemp(atemp<5) = 0;
            surB5 = conv2(atemp,surVec,'same');% have at least one surronding bigger than 5mm/h
            atemp(surB5<1) = 0;% ensure at least 2 connected is higher than 5mm/h
            
            atemp = conv2(atemp,allVec/10,'same');%%%%%%%%%%0515Final
            As0(:,:,i) = atemp;
            
        end
        % As0 = As;
        pm = squeeze(nanmax(nanmax(As0,[],1),[],2));
        indmax = find(pm==nanmax(pm(:)),1);
        A = squeeze(As(:,:,indmax));
        T = Ts(indmax);
        
    end
end
