% if ~logical(numel(gcp('nocreate')))
%     poolH = parpool('local',2);
% end

face.Color = [0 0.447 0.741];
face.alpha = 0.35;
figH = findobj('type','figure');
if logical(numel(figH))
    figH = figH(1);
    set(0,'CurrentFigure',figH);clf;
else
    figH = figure();
end
figH.WindowStyle = 'docked';

nSub = 2;
for SubPlt=1:nSub
    axH(SubPlt) = subplot(1,nSub,SubPlt);
    [axH(SubPlt).XGrid, axH(SubPlt).XMinorGrid, ...
        axH(SubPlt).YGrid, axH(SubPlt).YMinorGrid] = deal('on');
    axH(SubPlt).DataAspectRatio = [1 1 1];
    axH(SubPlt).Visible = 'off';
    axH(SubPlt).YLim = [0 12];
    axH(SubPlt).XLim = [-1 11];
    [axH(SubPlt).XLimMode, axH(SubPlt).YLimMode] = deal('manual');
end
clearvars SubPlt nSub

%% plot setup
% SupTitle = sgtitle('simulation');

% initialise the plot with dummy objects (for simplicity we use the first simulation step)
% this allows us ti only update the data of the plot objects, which is
% significantly faster than plotting the objects every step

% raw material side
set(figH,'CurrentAxes',axH(1));
ptH1 = patch('Faces',1:length(mat.pgon.Vertices),...
             'Vertices',mat.pgon.Vertices,...
             'FaceColor',face.Color,'FaceAlpha',face.alpha);
ptH2 = patch('Faces',1:length(toolpath(1).pgon.Vertices),...
             'Vertices',toolpath(1).pgon.Vertices,...
             'FaceColor',mod(face.Color+.5,1),'FaceAlpha',face.alpha);

% cut operation result side
set(figH,'CurrentAxes',axH(2));
ptH3 = patch('Faces',1:length(part(1).pgon.Vertices),...
             'Vertices',part(1).pgon.Vertices,...
             'FaceColor',face.Color,'FaceAlpha',face.alpha);

M = repmat(getframe,numel(part),1);  % grab a dummy frame and preallocate RAM with it

plttime = tic;
fprintf(1,'[ %s ] starting plotting...\n',datestr(now,'HH:mm:SS'));
for step=1:numel(part)
    stepdur = tic;
%     SupTitle.String = sprintf('step % .4i',step);
    sgtitle(sprintf('step % .4i',step))
    xpos = part(step).pos(3);
    
    % subplot links
    ptH1.Faces = 1:length(mat.pgon.Vertices);
    ptH1.Vertices = mat.pgon.Vertices;
    
    ptH2.Faces = 1:length(toolpath(step).pgon.Vertices);
    ptH2.Vertices = toolpath(step).pgon.Vertices;
    
    % subplot rechts
    ptH3.Faces = 1:length(part(step).pgon.Vertices);
    ptH3.Vertices = part(step).pgon.Vertices;
%     drawnow;
    M(step) = getframe;
    fprintf(1,'[ %s ] plotting step % i @ xpos=%.3f mm took %.3f sec.\n',datestr(now,'HH:mm:SS'),step,xpos,toc(stepdur));
end
fprintf(1,'[ %s ] finished plotting, took %.3f secs.\n',datestr(now,'HH:mm:SS'),toc(plttime))
clearvars plttime step