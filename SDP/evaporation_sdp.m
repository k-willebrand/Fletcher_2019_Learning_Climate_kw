function  [E]  = evaporation_sdp(storage, T, P, climParam, runParam ) 

[numRuns,~] = size(T);
numYears = runParam.steplen;

LAT = -3.96;  
WATYEAR = 1; % Start in January
days = repmat([31 28 31 30 31 30 31 31 30 31 30 31], numRuns, numYears);

% Calcuate temperature range; assume fixed
load('Mwache_hydro_data', 'Tmax_1962_2012', 'Tmin_1962_2012')
T_range = Tmax_1962_2012' - Tmin_1962_2012';
T_range_mon = TS2Mon(T_range);
T_range_mon_avg = mean(T_range_mon, 1); % This is starting in June
TEMPRANGE = [T_range_mon_avg(7:end) T_range_mon_avg(1:6)]; % Now starting in January
TEMPRANGE = repmat(TEMPRANGE, numRuns, numYears);

% Calculate PET using Modifed Hargreaves
P_mmd = P ./ days; % mm/m to mm/d
PET  = ModHargreaves4(LAT,WATYEAR,T,TEMPRANGE,P_mmd);
PET_mpm = PET .* days /1E3; 

% Calcuate area for storage volume
load('area_storage.mat') % area (column 1) in sq km; stor (column 2) in MCM
index = find(storage < areaStorage(:,2), 1);
a = ( storage - areaStorage(index,2) ) / (areaStorage(index-1,2) - areaStorage(index,2));
storage = (1-a)* areaStorage(index,2) + a * areaStorage(index-1,2);
area = (1-a)* areaStorage(index,1) + a * areaStorage(index-1,1);

% Calculate net evaporation over total area
P_mpm = P /1E3;
Net_E_mpm = PET_mpm - P_mpm; % mpm
Net_E_cmpm = Net_E_mpm * area*1E6; %cmpm
E = cmpm2mcmpy(Net_E_cmpm); %mcmpy




