%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% group and stack the data into 4-tuples [ fileno(i)  FRET(i) FRET(i+1) n ]
%       1. file number
%       2. fret of the state
%       3. fret of the next state (or NaN if last state in a trace)
%       4. length of the state
% optionally, remove the first and last dwell states in each trace (default)
%
% input: cell array of paths (vectors of FRET states for each trace pair that have have been smoothed over by vbFRET)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dwellData = getRawDwell(paths, removeFirstLast)

if nargin < 2
	removeFirstLast = false;
end

dwellData = [];

for p=1:max(paths(:,1))
	path = paths(paths(:,1)==p,2);
    if isempty(path)
        continue
    else 
    end
	% transition happens on frames when next state is different from current state
	% and on last frame
	transitions = find([path(1:end-1) ~= path(2:end); true]); 
	lengths = transitions - [0; transitions(1:end-1)];
	fret = path(transitions);
	nextFret = [path(transitions(1:end-1)+1); NaN];
	if ~removeFirstLast
		dwellData = [dwellData; p*ones(size(fret)), fret, nextFret, lengths];
	elseif length(transitions) > 2 % do not keep first and last transitions
		dwellData = [dwellData; p*ones(size(fret,1)-2,1), fret(2:end-1), nextFret(2:end-1), lengths(2:end-1)];
	end
end

end