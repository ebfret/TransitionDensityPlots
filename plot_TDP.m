function [] = plot_TDP(filename, varargin)

%specify required input and parameters defaults
p = inputParser();

%the number of bins on one axis to count FRET values before and after transitions
p.addParamValue('bins',50,@isnumeric);
%whether to plot unsmoothed TDP or smoothed TDP
p.addParamValue('smoothing',true,@islogical)
%whether to export the dwelldata array as a text file
p.addParamValue('exportdwelldata',false,@islogical)
%whether to normalize by total number of frames
p.addParamValue('normbyframes',false,@islogical)
%whether to normalize by total number of transitions
p.addParamValue('normbytransitions',false,@islogical)
%the lower and upper limit ([lower upper]) of the color bar
p.addParamValue('colorlim',[],@isnumeric);
%set the colormap
p.addParamValue('cmap','jet_2floor',@isstring);

%the minimum and maximum bounds of the histogram
p.addParamValue('fret_min',0.0,@isnumeric)
p.addParamValue('fret_max',1.0,@isnumeric)

%unsmoothed TDP parameteres
%the number frames to cutoff all traces at; if 0,
%the program sets it to the length of the longest trace in the loaded
%data
p.addParamValue('cutofft',0,@isnumeric);

%smoothed TDP parameters
%the variance of the smoothing Gaussian function
p.addParamValue('var',.00075,@isnumeric);
%the number of grid points on one axis to apply smoothing
p.addParamValue('resolution',800,@isnumeric);
%whether to discard the first and last transitions of each trace
p.addParamValue('discardfirstlast',false,@islogical);

p.parse(varargin{:});

%load pathdata from concactenated .dat file
pathdata = load(filename);
%turn pathdata into dwelldata
dwelldata = getRawDwell(pathdata,p.Results.discardfirstlast);
%remove NaN transitions
dwelldata = dwelldata(~isnan(dwelldata(:,3)),:);
%export dwelldata if desired
if p.Results.exportdwelldata
    dlmwrite([filename '_dwelldata.txt'],dwelldata,'Delimiter','\t')
end

% plot a smoothed TDP
if p.Results.smoothing

    %generate X and Y bins
    X = linspace(p.Results.fret_min, p.Results.fret_max, p.Results.bins)';
    Y = X';

    %generate start and stop vectors
    start = dwelldata(:, 2);
    stop = dwelldata(:, 3);

    %generate 2D transition histogram
    for j = (1:p.Results.bins)
        for i = (1:p.Results.bins)
            Z(j, i) = sum(exp(-((X(i) - start).^2 + (Y(j) - stop).^2)/(2*p.Results.var)));
        end
    end

    %apply normalization if desired
    if p.Results.normbyframes
        Z = Z/length(pathdata(:,1));
    end
    if p.Results.normbytransitions
        Z = Z/length(dwelldata(:,1));
    end

    %apply interpolation
    %set axis limits -0.2-1.2 or 0-1
    XI = linspace(p.Results.fret_min, p.Results.fret_max, p.Results.resolution);
    ZI = interp2(X, Y, Z, XI', XI, 'cubic');

% plot an unsmoothed TDP
else

    if p.Results.cutofft ~= 0
        %get idealized FRET values
        F = getIdealFRET(pathdata,p.Results.cutofft);
    else
        [m, f] = mode(pathdata(:,1));
        cutofft = f;
        F = getIdealFRET(pathdata,cutofft);
    end

    %generate the histogram
    %set axis limits -0.2-1.2 or 0-1
    X = linspace(p.Results.fret_min, p.Results.fret_max, p.Results.bins)';
    Z = getTransitions2(F, p.Results.bins, true);

    %apply normalization if desired
    if p.Results.normbyframes
        Z = Z/length(pathdata(:,1));
    end
    if p.Results.normbytransitions
        Z = Z/length(dwelldata(:,1));
    end

end

%plot TDP
if p.Results.smoothing
    figure, pcolor(XI', XI, ZI);
else
    figure, pcolor(X,X,Z);
end

% set the colormap
if p.Results.cmap == 'jet_2floor'
  colormap([1 1 0.8; ones(5, 3); colormap('jet')]);
else
  colormap(p.Results.cmap);
end

% set plot options
colorbar;
shading flat;
axis square tight;

% add plot labels
xlabel('FRET before transition');
ylabel('FRET after transition');
title('FRET Transition Density') ;

% set the min and max colors
if ~isempty(p.Results.colorlim)
   caxis(p.Results.colorlim)
end

%display relevant statistics
disp(['Plotted ' int2str(length(dwelldata(:,1))) ' transitions from ' ...
    int2str(length(unique(pathdata(:,1)))) ' traces'])
