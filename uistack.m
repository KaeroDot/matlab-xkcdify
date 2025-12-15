function uistack(comp, moveto, step)
% UISTACK Reorder visual stacking of graphics objects
%
% Syntax:
%   uistack(comp)
%   uistack(comp, moveto)
%   uistack(comp, moveto, step)
%
% Description:
%   uistack(comp) shifts the specified graphics object(s) up one level 
%   within the visual stacking order. If comp is a vector of objects, 
%   uistack shifts each object in the vector up one level.
%
%   uistack(comp, moveto) moves the graphics object to the specified 
%   position in the stack. moveto can be:
%     'up'     - Move up step levels (default: 1)
%     'down'   - Move down step levels (default: 1)
%     'top'    - Move to the top (front) of the stack
%     'bottom' - Move to the bottom (back) of the stack
%
%   uistack(comp, moveto, step) specifies the number of levels to move
%   the object up or down. Only applies when moveto is 'up' or 'down'.
%
% Input Arguments:
%   comp   - Graphics object handle or vector of handles
%   moveto - Direction/position: 'up', 'down', 'top', or 'bottom' 
%            (default: 'up')
%   step   - Number of levels to move (default: 1)
%
% Examples:
%   % Create overlapping rectangles
%   r1 = rectangle('Position', [0 0 2 2], 'FaceColor', 'r');
%   r2 = rectangle('Position', [1 1 2 2], 'FaceColor', 'b');
%   
%   % Bring red rectangle to front
%   uistack(r1, 'top');
%
%   % Move blue rectangle down one level
%   uistack(r2, 'down');
%
% Note:
%   This is a GNU Octave compatible implementation. Objects must share
%   the same parent for reordering to work properly.
%
% See also: set, get

% Copyright (c) 2025 - GNU Octave compatible implementation

  % Input validation
  if nargin < 1 || nargin > 3
    print_usage();
  endif
  
  % Set default values
  if nargin < 2 || isempty(moveto)
    moveto = 'up';
  endif
  
  if nargin < 3 || isempty(step)
    step = 1;
  endif
  
  % Validate moveto argument
  if ~ischar(moveto)
    error('uistack: moveto must be a string');
  endif
  
  moveto = lower(moveto);
  valid_moveto = {'up', 'down', 'top', 'bottom'};
  if ~any(strcmp(moveto, valid_moveto))
    error('uistack: moveto must be ''up'', ''down'', ''top'', or ''bottom''');
  endif
  
  % Validate step argument
  if ~isnumeric(step) || step < 1 || fix(step) ~= step
    error('uistack: step must be a positive integer');
  endif
  
  % Validate comp argument - must be valid graphics handles
  if ~all(isgraphics(comp))
    error('uistack: comp must be valid graphics object handle(s)');
  endif
  
  % Process each component
  for i = 1:numel(comp)
    h = comp(i);
    
    % Get parent
    parent = get(h, 'Parent');
    if isempty(parent)
      warning('uistack: object has no parent, cannot reorder');
      continue;
    endif
    
    % Get all children of parent
    children = get(parent, 'Children');
    if isempty(children)
      continue;
    endif
    
    % Find current position
    current_idx = find(children == h);
    if isempty(current_idx)
      warning('uistack: object not found in parent''s children');
      continue;
    endif
    
    n = length(children);
    
    % Calculate new position based on moveto
    % Note: In MATLAB/Octave, Children are stored in reverse visual order
    % The first element (index 1) is on TOP (front)
    % The last element (index n) is on BOTTOM (back)
    switch moveto
      case 'top'
        new_idx = 1;
        
      case 'bottom'
        new_idx = n;
        
      case 'up'
        % Moving up in visual stack means moving toward index 1
        new_idx = max(1, current_idx - step);
        
      case 'down'
        % Moving down in visual stack means moving toward index n
        new_idx = min(n, current_idx + step);
        
      otherwise
        error('uistack: invalid moveto value');
    endswitch
    
    % Reorder if position changed
    if new_idx ~= current_idx
      % Remove object from current position
      children(current_idx) = [];
      
      % Calculate insert position in the modified array
      % We want the element to end up at position new_idx in the final array.
      % After removing from current_idx, we have n-1 elements.
      % The insert position in this intermediate array is simply new_idx,
      % because we're specifying where it should be in the final result.
      insert_idx = new_idx;
      
      % Insert at new position using 1-based indexing
      % Note: insert_idx can be from 1 to n (where n is original length)
      if insert_idx <= 1
        % Insert at the beginning
        children = [h; children];
      elseif insert_idx > length(children)
        % Insert at the end (append)
        children = [children; h];
      else
        % Insert in the middle: put h at position insert_idx
        % This means: elements [1..insert_idx-1], then h, then [insert_idx..end]
        children = [children(1:insert_idx-1); h; children(insert_idx:end)];
      endif
      
      % Set the reordered children
      set(parent, 'Children', children);
    endif
  endfor
  
endfunction


%!demo
%! % Create overlapping rectangles
%! figure();
%! red = rectangle('Position', [0 0 2 2], 'FaceColor', 'r')
%! hold on;
%! blue = rectangle('Position', [0.5 1 2 2], 'FaceColor', 'b')
%! green = rectangle('Position', [1.5 0.5 2 2], 'FaceColor', 'g')
%! axis equal;
%! axis([-0.5 3.5 -0.5 3.5]);
%! title('Initial order: red (back), blue (middle), green (front)');
%! children = get(gca, 'Children')
%! input('Press Enter to continue...');
%! 
%! % Bring red rectangle to front
%! uistack(red, 'top');
%! title('After uistack(r1, ''top''): red on top (and blue in back, green in middle)');
%! children = get(gca, 'Children')
%! input('Press Enter to continue...');
%! 
%! % Move red down one level
%! uistack(red, 'down', 1);
%! children = get(gca, 'Children')
%! title('After uistack(r1, ''down'', 1): red in middle');

%!shared r1, r2, r3, children, hf
%! hf = figure('visible', 'on');
%! r1 = rectangle('Position', [0 0 1 1], 'FaceColor', 'r');
%! r2 = rectangle('Position', [0.5 0 1 1], 'FaceColor', 'g');
%! r3 = rectangle('Position', [0 0.5 1 1], 'FaceColor', 'b');
%! % Get initial order
%! children = get(gca, 'Children')
%!assert(children(3) == r1);  % r1 on bottom
%!assert(children(2) == r2);  % r2 in middle
%!assert(children(1) == r3);  % r3 on top
%! 
%! % Move r1 to top
%! uistack(r1, 'top');
%! children = get(gca, 'Children')
%!assert(children(3) == r2);  % r2 now on bottom
%!assert(children(2) == r3);  % r3 now in middle
%!assert(children(1) == r1);  % r1 now on top
%! 
%! % Move r1 back to bottom
%! uistack(r1, 'bottom');
%! children = get(gca, 'Children')
%!assert(children(3) == r1);  % r1 on bottom
%!assert(children(2) == r2);  % r2 in middle
%!assert(children(1) == r3);  % r3 on top
%!
%! % Move r1 to the top and down by 1
%! uistack(r1, 'top');
%! uistack(r1, 'down', 1);
%! children = get(gca, 'Children')
%!assert(children(3) == r2);  % r2 on bottom
%!assert(children(2) == r1);  % r1 in middle
%!assert(children(1) == r3);  % r3 on top
%! close(hf);