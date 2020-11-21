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
        l3dHc       % line handle, 3d plot, candidate points
        LegStr = {'trajectory','seek points','simulation'};
        zInt
        rWst
        numPt
        ptID        % id of the point of interest within the tool point cloud
        xscope = [0 2*pi];
        scroll = [-6/4*pi 2/4*pi];
        extension = [80 80];    % [x y]
        wkpc = struct();
        bfun
        tAng2zH
        posFun
        distWst
    end
    
    methods
        function obj = plotSimulation(zInt,rWst,numPt,ptID,bfun,tAng2zH,posFun,distWst)
            %PLOTSIMULATION Construct an instance of this class
            %   Detailed explanation goes here
            obj.zInt = zInt;
            obj.rWst = rWst;
            obj.numPt = numPt;
            obj.ptID = ptID;
            obj.l3dH = gobjects(numPt,1);
            obj.bfun = bfun;
            obj.tAng2zH = tAng2zH;
            obj.posFun = posFun;
            obj.distWst = distWst;
            obj.wkpc = makeLimVert(obj);            % create vertices for the workpiece limit plots
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
            axis(obj.ax3dH, 'vis3d');
            axSetup();
            
            % trajectory line handles: analytic traj, seek, solution, workpiece limit
            obj.lTH(1) = animatedline(obj.axH(1),'Color','#EDB120');
            obj.lTH(2) = animatedline(obj.axH(1), 'LineStyle','none','Marker','*','Color','#77AC30'); % seek
            obj.lTH(3) = animatedline(obj.axH(1), 'LineStyle','-',   'Marker','.','Color','#A2142F'); % engaged traj
            obj.limH(1) = animatedline(obj.axH(1), 'LineStyle','--','Color','r','MaximumNumPoints',2); % upper workpiece limit
            obj.limH(1).UserData.limval = obj.zInt(2);
            legend(obj.LegStr);
            
            % radius from centre axis line handles: analytic rad, seek, solution, workpiece limit
            obj.lRH(1) = animatedline(obj.axH(2),'Color','#EDB120');
            obj.lRH(2) = animatedline(obj.axH(2), 'LineStyle','none','Marker','*','Color','#77AC30'); % seek
            obj.lRH(3) = animatedline(obj.axH(2), 'LineStyle','-',   'Marker','.','Color','#A2142F'); % engaged traj
            obj.limH(2) = animatedline(obj.axH(2), 'LineStyle','--','Color','r','MaximumNumPoints',2); % outer workpiece limit
            obj.limH(2).UserData.limval = obj.rWst;
            legend(obj.LegStr);
            
            obj.axH = obj.axH(1);       % only the main axes handle is required
            %% 3d data
            % 3d plotting line handles
            obj.l3dHs = animatedline(obj.ax3dH, 'LineStyle','none','Marker','*','Color','#77AC30'); % seek
            obj.l3dHc = animatedline(obj.ax3dH, 'LineStyle','none','Marker','*','Color','y'); % cut candidate
            % engaged traj
            for ln = 1:obj.numPt
                obj.l3dH(ln) = animatedline(obj.ax3dH, 'LineStyle','-',   'Marker','.','Color','#A2142F');
            end
            str = {'top','btm'};
            for ln = 1:2
                v = obj.wkpc.(str{ln});     % pull vertix data
                patch(obj.ax3dH,'XData',v(1,:),'YData',v(2,:),'ZData',v(3,:),'FaceColor','#D95319','FaceAlpha',0.25,'EdgeColor','none');
            end
            v = obj.wkpc.cyl;
            surface(obj.ax3dH,v(1,:),v(2,:),v(3,:),'FaceColor','#D95319','FaceAlpha',0.25,'EdgeColor','none');
        end
        
        function wkpc = makeLimVert(obj)
            wkpc.top = rectangleVert([obj.extension*2,max(obj.zInt)],'coordinateSystem','c','dimension',3);
            wkpc.btm = rectangleVert([obj.extension*2,min(obj.zInt)],'coordinateSystem','c','dimension',3);
            [cWkstx,cWksty] = cylinder(obj.rWst,1e2);
            cWkstz = repmat(obj.zInt(:),1,size(cWkstx,2));
            wkpc.cyl = [cWkstx;cWksty;cWkstz];
        end
        
        function plotSeek(obj,B)
            addpoints(obj.lTH(2),B,obj.tAng2zH(B,obj.ptID));
            addpoints(obj.lRH(2),B,obj.distWst(B,obj.ptID));
            aktPos = obj.posFun(repmat(B,1,4));
            addpoints(obj.l3dHs,aktPos(1,:),aktPos(2,:),aktPos(3,:));
            obj.scrollPlot(B);
        end
                
        function plotTraj(obj,B)
            bvec = linspace(B,B+2*pi,1e2);
            addpoints(obj.lTH(1),bvec,obj.tAng2zH(bvec,obj.ptID));
            addpoints(obj.lRH(1),bvec,obj.distWst(bvec,obj.ptID));
        end
        
        function plotCandidate(obj,B)
            cutC = obj.posFun(B);
            addpoints(obj.l3dHc,cutC(1,:),cutC(2,:),cutC(3,:));
        end
        
        function plotCut(obj,B)
            addpoints(obj.lTH(3),B(obj.ptID), obj.tAng2zH(B(obj.ptID),obj.ptID));
            addpoints(obj.lRH(3),B(obj.ptID), obj.distWst(B(obj.ptID),obj.ptID));
            obj.scrollPlot(B(obj.ptID));
            aktPos = obj.posFun(B);
            for ln = 1:obj.numPt
                addpoints(obj.l3dH(ln),aktPos(1,ln),aktPos(2,ln),aktPos(3,ln))
            end
        end
        
        function scrollPlot(obj,x)
            obj.axH.XLim = max([obj.xscope; x+obj.scroll]);
            for n = 1:numel(obj.limH)
                limval = obj.limH(n).UserData.limval;
                addpoints(obj.limH(n),obj.axH.XLim,[limval limval]);
            end
            drawnow limitrate
        end
        
        function finishedCut(obj,B)
            addpoints(obj.lTH(3),B,NaN);
            addpoints(obj.lRH(3),B,NaN);
            for ln = 1:obj.numPt
                addpoints(obj.l3dH(ln),NaN,NaN,NaN)
            end
        end
    end
    
end