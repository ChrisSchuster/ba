classdef plotSimulation
    %PLOTSIMULATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        figH                    % figure handle
        axH = gobjects(2,1);    % axis handle figure 1
        ax3dH       % axis handle figure 2 (3d figure)
        lTH = gobjects(3,1);    % line handle, trajectory plot
        lRH = gobjects(3,1);    % line handle, radius/distance plot
        limH = gobjects(2,1);   % line hanlde, limits of workpiece extensions
        l3dH                    % line handle, 3d plot, trajectories of tool points
        l3dHs       % line handle, 3d plot, seek points
        l3dHc       % line handle, 3d plot, cut points
        LegStr = {'trajectory','seek points','simulation'};
        zInt
        rWst
        numPt
        xscope = [0 2*pi];
        scroll = [-6/4*pi 2/4*pi];
        extension = [80 80];    % [x y]
    end
    properties (Dependent)
        limTop
        limBtm
    end
    
    methods
        function obj = plotSimulation(zInt,rWst,numPt)
            %PLOTSIMULATION Construct an instance of this class
            %   Detailed explanation goes here
            obj.zInt = zInt;
            obj.rWst = rWst;
            obj.numPt = numPt;
            obj.l3dH = gobjects(numPt,1);
            obj = initPlotting(obj);
        end
        
        function obj = initPlotting(obj)
            obj.figH = getFigH(2,'WindowStyle','docked'); % create figure handle and window
            tH = tiledlayout(obj.figH(1),2,1);
            tH.Padding = 'compact';
            tH.TileSpacing = 'compact';
            pH = pan(obj.figH(1));
            pH.Motion = 'horizontal';
            pH.Enable = 'on';
            %% Simulation Data
            % create simulation axes handles
            obj.axH(1) = nexttile(tH,1);
            obj.axH(1).Title.String = 'Trajectory';
            obj.axH(1).XTickLabel = [];
            obj.axH(2) = nexttile(tH,2);
            obj.axH(2).Title.String = 'Distance';
            linkaxes(obj.axH,'x')
%             obj.axH = obj.axH(1);       % only the main axes handle is required
            
            % create 3d axes handles
            obj.ax3dH = axes(obj.figH(2));
            axis vis3d;
            axSetup();
            
            % trajectory line handles: analytic traj, seek, solution, workpiece limit
            obj.lTH(1) = animatedline(obj.axH(1),'Color','#EDB120');
            obj.lTH(2) = animatedline(obj.axH(1), 'LineStyle','none','Marker','*','Color','#77AC30'); % seek
            obj.lTH(3) = animatedline(obj.axH(1), 'LineStyle','-',   'Marker','.','Color','#A2142F'); % engaged traj
            obj.limH(1) = animatedline(obj.axH(1), 'LineStyle','--','Color','r','MaximumNumPoints',2); % upper workpiece limit
            legend(obj.LegStr);
            
            % radius from centre axis line handles: analytic rad, seek, solution, workpiece limit
            obj.lRH(1) = animatedline(obj.axH(2),'Color','#EDB120');
            obj.lRH(2) = animatedline(obj.axH(2), 'LineStyle','none','Marker','*','Color','#77AC30'); % seek
            obj.lRH(3) = animatedline(obj.axH(2), 'LineStyle','-',   'Marker','.','Color','#A2142F'); % engaged traj
            obj.limH(2) = animatedline(obj.axH(2), 'LineStyle','--','Color','r','MaximumNumPoints',2); % outer workpiece limit
            legend(obj.LegStr);
            %% 3d data
            % 3d plotting line handles
            obj.l3dHs = animatedline(obj.ax3dH, 'LineStyle','none','Marker','*','Color','#77AC30'); % seek
            obj.l3dHc = animatedline(obj.ax3dH, 'LineStyle','none','Marker','*','Color','y'); % cut candidate
            % engaged traj
            for ln = 1:obj.numPt
                obj.l3dH(ln) = animatedline(obj.ax3dH, 'LineStyle','-',   'Marker','.','Color','#A2142F');
            end
            patch(obj.ax3dH,'XData',obj.limTop(1,:),'YData',obj.limTop(2,:),'ZData',obj.limTop(3,:),'FaceColor','#D95319','FaceAlpha',0.25,'EdgeColor','none');
            patch(obj.ax3dH,'XData',obj.limBtm(1,:),'YData',obj.limBtm(2,:),'ZData',obj.limBtm(3,:),'FaceColor','#D95319','FaceAlpha',0.25,'EdgeColor','none');
            
            
        end
        
        function limTop = get.limTop(obj)
            limTop = rectangleVert([obj.extension*2,obj.zInt(1)],'coordinateSystem','c','dimension',3);
            
        end
        function limBtm = get.limBtm(obj)
            limBtm = rectangleVert([obj.extension*2,obj.zInt(2)],'coordinateSystem','c','dimension',3);
        end
    end
    
end

