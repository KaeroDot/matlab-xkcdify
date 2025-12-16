function xkcdify(axesList, renderAxesLines)
%XKCDIFY redraw an existing axes in an XKCD style
%
%   XKCDIFY( AXES ) re-renders all childen of AXES to have a hand drawn
%   XKCD style, http://xkcd.com, AXES can be a single axes or a vector of axes
%
%   NOTE: Only plots of type LINE and PATCH are re-rendered. This should 
%   be sufficient for the majority of 2d plots such as:
%       - plot
%       - bar
%       - boxplot
%       - etc...
%
%   NOTE: This function does not alter the actual style of the axes
%   themselves, that functionality will be added in the next version.  I
%   still have to figure out the best way to do this, if you have a
%   suggestion please email me!
%
%   Finally the most up to date version of this code can be found at:
%   https://github.com/slayton/matlab-xkcdify
%
% Copyright(c) 2012, Stuart P. Layton <stuart.layton@gmail.com> MIT
% http://stuartlayton.com

% Revision History
%   2012/10/04 - Initial Release

    % ===== XKCDIFY CONFIGURATION CONSTANTS =====
    % Font settings
    persistent XKCD_FONT_NAME = 'xkcd Script';
    persistent XKCD_FONT_SIZE_NORMAL = 16;    % For axes, labels, tick labels
    persistent XKCD_FONT_SIZE_TITLE = 18;     % For plot titles
    
    % Label spacing (in pixels)
    persistent XKCD_XLABEL_SPACE = 35;        % Extra space at bottom for xlabel
    persistent XKCD_YLABEL_SPACE = 45;        % Extra space at left for ylabel
    % ==========================================
    
    if nargin==0
        error('axHandle must be specified');
    elseif ~all( ishandle(axesList) )
        error('axHandle must be a valid axes handle');
    elseif ~all( strcmp( get(axesList, 'type'), 'axes') )
        error('axHandle must be a valid axes handle');
    end
    
    if nargin==1
        renderAxesLines = 1;  % Default to rendering hand-drawn axes
    end
    
    for axN = 1:numel(axesList)
        axHandle = axesList(axN);

        pixPerX = [];
        pixPerY = [];
   
        axChildren = get(axHandle, 'Children');
        operareOnChildren(axChildren, axHandle);
    
        if renderAxesLines == 1
            renderNewAxesLine(axHandle)
            % Hide the original axes since we're drawing hand-drawn ones
            set(axHandle, 'XColor', 'none', 'YColor', 'none');
        end
        
        % Change all text fonts to xkcd Script
        changeAllTextFonts(axHandle);
        
    end

    
    
function renderNewAxesLine(ax)
    
    isBoxOn = strcmp( get(ax,'Box'), 'on' );
    set(ax,'Box', 'off');
    
    % Check if xlabel or ylabel exist and need space
    origXLabel = get(ax, 'XLabel');
    origYLabel = get(ax, 'YLabel');
    hasXLabel = ~isempty(origXLabel) && origXLabel ~= 0 && ~isempty(get(origXLabel, 'String'));
    hasYLabel = ~isempty(origYLabel) && origYLabel ~= 0 && ~isempty(get(origYLabel, 'String'));
    
    % Get original axes position and adjust to make room for labels with larger fonts
    pos = getAxesPositionInUnits(ax,'Pixels');
    
    % Add space for labels by shrinking the axes and moving it
    extraBottomSpace = 0;
    extraLeftSpace = 0;
    
    if hasXLabel
        extraBottomSpace = XKCD_XLABEL_SPACE;
    endif
    
    if hasYLabel
        extraLeftSpace = XKCD_YLABEL_SPACE;
    endif
    
    % Adjust original axes position to make room for labels
    if extraLeftSpace > 0 || extraBottomSpace > 0
        set(ax, 'Units', 'pixels');
        pos(1) = pos(1) + extraLeftSpace;
        pos(2) = pos(2) + extraBottomSpace;
        pos(3) = pos(3) - extraLeftSpace;
        pos(4) = pos(4) - extraBottomSpace;
        set(ax, 'Position', pos);
    endif
    
    % Get updated position and limits
    pos = getAxesPositionInUnits(ax,'Pixels');
    origXLim = get(ax, 'XLim');
    origYLim = get(ax, 'YLim');
    
    % Create new axes with exactly the same position and limits as original
    newAxes = axes('Units', 'pixels', 'Position', pos, 'Color', 'none');
    set(newAxes, 'XLim', origXLim, 'YLim', origYLim);
    set(newAxes,'Units', get(ax,'Units'), 'XTick', [], 'YTick', []);
    
    xlim = get(newAxes,'XLim');
    ylim = get(newAxes, 'YLim');
    ranges = [abs(xlim(2) - xlim(1)) abs(ylim(2) - ylim(1))];
    
    % Small offsets for drawing axes slightly inside the plot area
    dx = 0.01 * ranges(1);
    dy = 0.01 * ranges(2);
    
    % Create hand-drawn axes with wobble (inspired by gnovice's xkcd_axes)
    axArgs = {'Parent', newAxes, 'Color', 'k', 'LineWidth', 3, 'Clipping', 'off'};
    
    % Number of points for wobbly lines
    xPoints = round(pos(3)/10);
    yPoints = round(pos(4)/10);
    
    % Y-axis (left): vertical line with horizontal wobble
    yAxisY = linspace(ylim(1), ylim(2), yPoints);
    yAxisX = xlim(1) + rand(1, yPoints).*0.005.*ranges(1);
    axLine(1) = line(yAxisX, yAxisY, axArgs{:});
    
    % X-axis (bottom): horizontal line with vertical wobble
    xAxisX = linspace(xlim(1), xlim(2), xPoints);
    xAxisY = ylim(1) + rand(1, xPoints).*0.005.*ranges(2);
    axLine(2) = line(xAxisX, xAxisY, axArgs{:});
    
    %if 'Box' is on then draw the top and right edges
    if isBoxOn
        % Right edge: vertical line with horizontal wobble
        rightY = linspace(ylim(1), ylim(2), yPoints);
        rightX = xlim(2) + rand(1, yPoints).*0.005.*ranges(1);
        axLine(3) = line(rightX, rightY, axArgs{:});
        
        % Top edge: horizontal line with vertical wobble
        topX = linspace(xlim(1), xlim(2), xPoints);
        topY = ylim(2) + rand(1, xPoints).*0.005.*ranges(2);
        axLine(4) = line(topX, topY, axArgs{:});
    end
    
    % Turn off axes box and grid, but keep labels visible
    set(newAxes, 'Box', 'off', 'XColor', 'none', 'YColor', 'none', 'XGrid', 'off', 'YGrid', 'off');
    
    % Draw tick marks and labels
    % X-axis ticks
    xTicks = get(ax, 'XTick');
    if ~isempty(xTicks)
        yTickPos = ylim(1);  % Position on the x-axis line (bottom of new axes)
        tickLength = 0.02 * ranges(2);  % Tick mark length
        
        for i = 1:length(xTicks)
            % Draw tick mark - xTicks values are already in the correct coordinate space
            line([xTicks(i) xTicks(i)], [yTickPos - tickLength, yTickPos + tickLength], ...
                 'Parent', newAxes, 'Color', 'k', 'LineWidth', 2, 'Clipping', 'off');
        end
        
        % Draw tick labels
        xLabels = get(ax, 'XTickLabel');
        if iscell(xLabels)
            yLabelPos = ylim(1) - 0.04 * ranges(2);
            for i = 1:length(xLabels)
                text(xTicks(i), yLabelPos, xLabels{i}, ...
                     'Parent', newAxes, 'HorizontalAlignment', 'center', ...
                     'VerticalAlignment', 'top', 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
            end
        endif
    end
    
    % Y-axis ticks
    yTicks = get(ax, 'YTick');
    if ~isempty(yTicks)
        xTickPos = xlim(1);  % Position on the y-axis line (left of new axes)
        tickLength = 0.02 * ranges(1);  % Tick mark length
        
        for i = 1:length(yTicks)
            % Draw tick mark - yTicks values are already in the correct coordinate space
            line([xTickPos - tickLength, xTickPos + tickLength], [yTicks(i) yTicks(i)], ...
                 'Parent', newAxes, 'Color', 'k', 'LineWidth', 2, 'Clipping', 'off');
        end
        
        % Draw tick labels
        yLabels = get(ax, 'YTickLabel');
        if iscell(yLabels)
            xLabelPos = xlim(1) - 0.04 * ranges(1);
            for i = 1:length(yLabels)
                text(xLabelPos, yTicks(i), yLabels{i}, ...
                     'Parent', newAxes, 'HorizontalAlignment', 'right', ...
                     'VerticalAlignment', 'middle', 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
            end
        endif
    end
    
    set(ax, 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
    
    % Copy axis labels from original axes as text objects in the new axes
    origXLabel = get(ax, 'XLabel');
    if ~isempty(origXLabel) && origXLabel ~= 0
        xlabelText = get(origXLabel, 'String');
        if ~isempty(xlabelText)
            % Position xlabel below the x-axis
            xLabelX = mean(xlim);
            xLabelY = ylim(1) - 0.12 * ranges(2);
            text(xLabelX, xLabelY, xlabelText, ...
                 'Parent', newAxes, 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'top', 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
        endif
    endif
    
    origYLabel = get(ax, 'YLabel');
    if ~isempty(origYLabel) && origYLabel ~= 0
        ylabelText = get(origYLabel, 'String');
        if ~isempty(ylabelText)
            % Position ylabel to the left of the y-axis, rotated
            yLabelX = xlim(1) - 0.12 * ranges(1);
            yLabelY = mean(ylim);
            text(yLabelX, yLabelY, ylabelText, ...
                 'Parent', newAxes, 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'bottom', 'Rotation', 90, ...
                 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
        endif
    endif
   
end


function operareOnChildren(C, ax)
    % iterate on the individual children but in reverse order
    % also ensure that C is treated as a row vector

    for c = fliplr( C(:)' )
    %for i = 1:nCh
        % we want to 
     %   c = C(nCh - i + 1);
        cType = get(c,'Type');

        switch cType
            case 'line'
                % cartoonify line only if children got any line
                if not(strcmp(get(c, 'linestyle'), 'none'))
                    cartoonifyLine(c, ax);
                end
            case 'patch'
                cartoonifyPatch(c, ax);
 
            case 'text'
                % Change text font to xkcd Script
                set(c, 'FontName', XKCD_FONT_NAME);
 
            case 'hggroup'              
                % if not a line or patch operate on the children of the
                % hggroup child, plot-ception!
                operareOnChildren( get(c,'Children'), ax); 
            otherwise
                warning('Received unsupportd child of type %s', cType);
        end        
    end
    
end

function cartoonifyLine(l,  ax)
    
    if nargin==2
        addMask = 1;
    end

    xpts = get(l, 'XData')';
    ypts = get(l, 'YData')';
    
    % Force line width to be at least 4
    currentLineWidth = get(l, 'LineWidth');
    if currentLineWidth < 4
        set(l, 'LineWidth', 4);
    end

    %only jitter lines with more than 1 point   
    if numel(xpts)>1 

        [pixPerX, pixPerY] = getPixelsPerUnitForAxes(ax);
 
        % I should figure out a better way to calculate this
        xJitter = 6 / pixPerX; 
        yJitter = 6 / pixPerY;

        if all( diff( ypts) == 0) 
            % if the line is horizontal don't jitter in X
            xJitter = 0;
        
        elseif all( diff( xpts) == 0)
            % if the line is veritcal don't jitter in y
            yJitter = 0;      
        end
        
        [xpts, ypts] = upSampleAndJitter(xpts, ypts, xJitter, yJitter);
               
    end
    
    set(l, 'XData', xpts , 'YData', ypts, 'linestyle', '-');
    
    
    addBackgroundMask(xpts, ypts, get(l, 'LineWidth') * 3, ax);
    
    % Bring the colored line back to top after adding the background mask
    uistack(l, 'top');

    
end

function cartoonifyAxesEdge(l, ax)
    
    xpts = get(l, 'XData')';
    ypts = get(l, 'YData')';

    %only jitter lines with more than 1 point   
    if numel(xpts)>1 

        [pixPerX, pixPerY] = getPixelsPerUnitForAxes(ax);
 
        % I should figure out a better way to calculate this
        xJitter = 3 / pixPerX; 
        yJitter = 3 / pixPerY;

        if all( diff( ypts) == 0) 
            % if the line is horizontal don't jitter in X
            xJitter = 0;
        
        elseif all( diff( xpts) == 0)
            % if the line is veritcal don't jitter in y
            yJitter = 0;      
        end
        
        [xpts, ypts] = upSampleAndJitter(xpts, ypts, xJitter, yJitter);
               
    end
    
    set(l, 'XData', xpts , 'YData', ypts, 'linestyle', '-');    
end



function [x, y] = upSampleAndJitter(x, y, jx, jy, n)

    % we want to upsample the line to have a number of that is proportional
    % to the number of pixels the line occupies on the screen. Long lines
    % will get a lot of samples, short points will get a few
    
    if nargin == 4 || n == 0
        n = getLineLength(x,y);  
        ptsPerPix = 1/4;
        n = ceil( n * ptsPerPix);
    end
   
    x = interp1( linspace(0, 1, numel(x)) , x, linspace(0, 1, n) );
    y = interp1( linspace(0, 1, numel(y)) , y, linspace(0, 1, n) );
    
    x = x + smooth( generateNoise(n) .* rand(n,1) .* jx )';
    y = y + smooth( generateNoise(n) .* rand(n,1) .* jy )';

end

function noise = generateNoise(n)
    noise = zeros(n,1);
    
    iStart = ceil(n/50);
    iEnd = n - iStart;
    
    i = iStart;
    while i < iEnd
        if randi(10,1,1) < 2
            
            upDown = randsample([-1 1], 1);
            
            maxDur = max( min(iEnd - i, 100), 1);
            duration = randi( maxDur , 1, 1);
            noise(i:i+duration) = upDown;
            i = i + duration;
        end    
        i = i +1;
    end
    noise = noise(:);
end

function addBackgroundMask(xpts, ypts, w, ax)
   
    bg = get(ax, 'color');
    line(xpts, ypts, 'linewidth', w, 'color', bg, 'Parent', ax);
    
end

function pos = getAxesPositionInUnits(ax, units)
    
    if strcmp( get( ax,'Units'), units )
        pos = get(ax,'Position');
        return;
    end
    % if the current axes contains a box plot then we need to create a
    % temporary axes as changing the units on a boxplot causes the
    % pos(4) to be set to 0
    axUserData = get(ax,'UserData');
    if ~isempty(axUserData) && iscell(axUserData) && strcmp(axUserData{1}, 'boxplot')
        axTemp = axes('Units','normalized','Position', get(ax,'Position'));
        set(axTemp,'Units', units);
        pos = get(axTemp,'position');
        delete(axTemp);
    else
        origUnits = get(ax,'Units');
        set(ax,'Units', 'pixels');
        pos = get(ax,'Position');
        set(ax,'Units', origUnits);
    end

    
end
function setAxesPositionInUnits(ax, pos, units)
    
    if strcmp( get( ax,'Units'), units )
        set(ax,'Position', pos);
        return;
    end
    
    % if the current axes contains a box plot then we need to create a
    % temporary axes as changing the units on a boxplot causes the
    % pos(4) to be set to 0
    axUserData = get(ax,'UserData');
    if ~isempty(axUserData) && iscell(axUserData) && strcmp(axUserData{1}, 'boxplot')
        axTemp = axes('Units', get(ax,'Units'), 'Position', get(ax,'Position'));
        origUnit = get(axTemp,'Units');
        set(axTemp,'Units', units);
        set(axTemp,'position', pos);
        set(axTemp, 'Units', origUnit);
        set(ax, 'Position', get(axTemp, 'Position') );
        delete(axTemp);
    else
        origUnits = get(ax,'Units');
        set(ax,'Units', units);
        set(ax,'Potision', pos);
        set(ax,'Units', origUnits);
    end
end

% Main function for converting units to pixels, refers to the main drawing
% axes
function [ppX ppY] = getPixelsPerUnit()

    if ~isempty(pixPerX) && ~ isempty(pixPerY)
        ppX = pixPerX;
        ppY = pixPerY;
        return;
    end
    [ppX ppY] = getPixelsPerUnitForAxes(axHandle);
end

% Worker function for converting units to pixels, can be used with any axes
% allowing it to be used with subsequently created axes that are involved
% in rendering the axes lines
function [px py] = getPixelsPerUnitForAxes(axH)
    %get the size of the current axes in pixels
    %get the lims of the current axes in plotting units
    %calculate the number of pixels per plotting unit
    pos = getAxesPositionInUnits(axH, 'Pixels');
   
    xLim = get(axH, 'XLim');
    yLim = get(axH, 'YLim');

    px = pos(3) ./ diff(xLim);
    py = pos(4) ./ diff(yLim);
end



function [ len ] = getLineLength(x, y)

    % convert x and y to pixels from units
    [pixPerX, pixPerY] = getPixelsPerUnit();
    x = x(:) * pixPerX; 
    y = y(:) * pixPerY;
    
    %compute the length of the line
    len = sum( sqrt( diff( x ).^2 + diff( y ).^2 ) );    
end


function v = smooth(v)
    % these values are pretty arbitrary, i should probably come up with a
    % better way to calculate them from the data
    
    a = 1/2;
    nPad = 10;
    % filter the yValues to smooth the jitter
    v = filtfilt(a, [1 a-1], [ ones(nPad ,1) * v(1); v; ones(nPad,1) * v(end) ]);
    v = filtfilt(a, [1 a-1], v);
    v = v(nPad+1:end-nPad);   
    v = v(:);

end

% This method is by far the buggiest part of the script. It appears to work,
% however it fails to retain the original color of the patch, and sets it to
% blue.  This doesn't prevent the user from reseting the color after the
% fact using set(barHandle, 'FaceColor', color) which IMHO is an acceptable
% workaround
function cartoonifyPatch(p, ax)
    
    xPts = get(p, 'XData');
    yPts = get(p, 'YData');
    cData = get(p, 'CData');
    
    nOld = size(xPts,1);
    
    xNew = [];
    yNew = [];
    cNew = [];
    
    oldVtx = get(p, 'Vertices');
    oldVtxNorm = get(p, 'VertexNormals');
    
    % Check if VertexNormals exist (they may be empty for 2D patches)
    hasVertexNormals = ~isempty(oldVtxNorm);
    
    nPatch = size(xPts, 2);
    nVtx  = size(oldVtx,1);
    
    newVtx = [];
    newVtxNorm = [];
    
    [pixPerX, pixPerY] = getPixelsPerUnit();
 
    xJitter = 6 / pixPerX;
    yJitter = 6 / pixPerY;

    
    nNew = 0;
    cNew = [];
    for i = 1:nPatch
        %newVtx( end+1,:) = oldVtx( 1 + (i-1)*nOld , : );
        [x, y] = upSampleAndJitter(xPts(:,i), yPts(:,i), xJitter, yJitter, nNew);


        xNew(:,i) = x(:);
        yNew(:,i) = y(:);
        nNew = numel(x);
        
        if ~isempty(cData)
            cNew(:,i) = interp1( linspace( 0 , 1, nOld), cData(:,i), linspace(0, 1, nNew));
        end
     
        
        newVtx(end+1,1:2) = oldVtx( 1 + (i-1)*(nOld+1), 1:2);
        
        if hasVertexNormals
            newVtxNorm( end+1, 1:3) = nan;
        endif
        

        % set the first and last vertex for each bar back in its original
        % position so everything lines up
        yNew([1, end], i) = yPts([1,end],i);
        xNew([1, end], i) = xPts([1,end],i);

      
        newVtx(end + (1:nNew), :) = [xNew(:,i), yNew(:,i)] ;
        
        if hasVertexNormals
            t = repmat( oldVtxNorm( 1+1 + (i-1)*(nOld+1) , : ), nNew, 1);
            newVtxNorm( end+ (1 : nNew) , : ) = t;
        endif
        
        addBackgroundMask(xNew(:,i), yNew(:,i), 6, ax);
       
    end
    
    newVtx(end+1, :) = oldVtx(end,:);
    
    if hasVertexNormals
        newVtxNorm(end+1, : ) = nan;
    endif
    
    
    % construct the new vertex data
    newFaces = true(size(newVtx,1),1);
    newFaces(1:nNew+1:end) = false;
    newFaces = find(newFaces);
    newFaces = reshape(newFaces, nNew, nPatch)';
    
    % I can't seem to get this working correct, so I'll set the color to
    % the default matlab blue not the same as 'color', 'blue'!
    newFaceVtxCData = [ 0 0 .5608 ];
      
    if hasVertexNormals
        set(p, 'CData', cNew, 'FaceVertexCData', newFaceVtxCData, 'Faces', newFaces,  ...
            'Vertices', newVtx, 'XData', xNew, 'YData', yNew, 'VertexNormals', newVtxNorm);
    else
        set(p, 'CData', cNew, 'FaceVertexCData', newFaceVtxCData, 'Faces', newFaces,  ...
            'Vertices', newVtx, 'XData', xNew, 'YData', yNew);
    endif
    %set(p, 'EdgeColor', 'none');
    
    % Bring the patch back to top after adding background masks
    uistack(p, 'top');
end

function changeAllTextFonts(ax)
    % Change font of text labels in the axes to xkcd Script
    % This includes title, xlabel, ylabel, zlabel AND tick labels via axes FontName
    
    % Set axes FontName and FontSize for tick labels
    set(ax, 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
    
    % Change title
    titleHandle = get(ax, 'Title');
    if ~isempty(titleHandle) && titleHandle ~= 0
        set(titleHandle, 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_TITLE);
    endif
    
    % Change xlabel
    xlabelHandle = get(ax, 'XLabel');
    if ~isempty(xlabelHandle) && xlabelHandle ~= 0
        set(xlabelHandle, 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
    endif
    
    % Change ylabel
    ylabelHandle = get(ax, 'YLabel');
    if ~isempty(ylabelHandle) && ylabelHandle ~= 0
        set(ylabelHandle, 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
    endif
    
    % Change zlabel (for 3D plots)
    zlabelHandle = get(ax, 'ZLabel');
    if ~isempty(zlabelHandle) && zlabelHandle ~= 0
        set(zlabelHandle, 'FontName', XKCD_FONT_NAME, 'FontSize', XKCD_FONT_SIZE_NORMAL);
    endif
    
end


end
