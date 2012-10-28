classdef EllTubeProjBasic<gras.ellapx.smartdb.rels.EllTubeBasic&...
        gras.ellapx.smartdb.rels.EllTubeTouchCurveProjBasic
    properties (Constant,Hidden, GetAccess=protected)
        N_SPOINTS=90;
    end
    methods (Access=protected)
        function dependencyFieldList=getTouchCurveDependencyFieldList(~)
            dependencyFieldList={'sTime','lsGoodDirOrigVec',...
                'projType','projSpecDimVec','MArray'};
        end
    end    
    methods (Access=protected)
        function [patchColor,patchAlpha]=getPatchColorByApxType(~,approxType)
            import gras.ellapx.enums.EApproxType;
            switch approxType
                case EApproxType.Internal
                    patchColor=[0 1 0];
                    patchAlpha=0.5;
                case EApproxType.External
                    patchColor=[0 0 1];
                    patchAlpha=0.3;
                otherwise,
                    throwerror('wrongInput',...
                        'ApproxType=%s is not supported',char(approxType));
            end
        end
        function [patchColor,patchAlpha]=getRegTubeColor(~,~)
                patchColor=[1 0 0];
                patchAlpha=1;
        end        
        %
        function hVec=plotCreateReachTubeFunc(self,hAxes,projType,...
                timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                ltGoodDirNormOrigVec,approxType,QArray,aMat,MArray,...
                varargin)
            import gras.ellapx.enums.EApproxType;
            fGetPatchColor=@(approxType)getPatchColorByApxType(self,approxType);
            hVec=self.plotCreateGenericTubeFunc(hAxes,...
                            timeVec,lsGoodDirOrigVec,sTime,...
                            approxType,QArray,aMat,fGetPatchColor);
            axis(hAxes,'tight');
            axis(hAxes,'normal');                        
            if approxType==EApproxType.External
                hTouchVec=self.plotCreateTubeTouchCurveFunc(...
                    hAxes,projType,...
                    timeVec,lsGoodDirOrigVec,ltGoodDirMat,sTime,...
                    xTouchCurveMat,xTouchOpCurveMat,ltGoodDirNormVec,...
                    ltGoodDirNormOrigVec,varargin{:});
                hVec=[hVec,hTouchVec];
            end
            if approxType==EApproxType.Internal
                fGetPatchColor=@(approxType)getRegTubeColor(self,approxType);
                hAddVec=self.plotCreateGenericTubeFunc(hAxes,...
                    timeVec,lsGoodDirOrigVec,sTime,...
                    approxType,MArray,aMat,fGetPatchColor);
                hVec=[hVec,hAddVec];
            end
        end
        function hVec=plotCreateRegTubeFunc(self,hAxes,~,...
                timeVec,lsGoodDirOrigVec,~,sTime,...
                ~,~,~,...
                ~,approxType,~,aMat,MArray,...
                varargin)
            import gras.ellapx.enums.EApproxType;
            
            if approxType==EApproxType.Internal
                fGetPatchColor=@(approxType)getRegTubeColor(self,approxType);                
                hVec=self.plotCreateGenericTubeFunc(hAxes,...
                                timeVec,lsGoodDirOrigVec,sTime,...
                                approxType,MArray,zeros(size(aMat)),...
                                fGetPatchColor);
            else
                hVec=[];
            end
        end        
        function hVec=plotCreateGenericTubeFunc(self,hAxes,...
                timeVec,lsGoodDirOrigVec,sTime,...
                approxType,QArray,aMat,fGetPatchColor)
            nSPoints=self.N_SPOINTS;
            goodDirStr=self.goodDirProp2Str(lsGoodDirOrigVec,sTime);
            patchName=sprintf('Tube, %s: %s',char(approxType),goodDirStr);
            [vMat,fMat]=gras.ellapx.plot.tri.build_etube2_pmodel(...
                QArray,aMat,timeVec,nSPoints);
            [patchColor,patchAlpha]=fGetPatchColor(approxType);
            %
            hVec=patch('FaceColor','interp','EdgeColor','none',...
                'DisplayName',patchName,...
                'FaceAlpha',patchAlpha,...
                'FaceVertexCData',repmat(patchColor,size(vMat,1),1),...
                'Faces',fMat,'Vertices',vMat,'Parent',hAxes,...
                'EdgeLighting','phong','FaceLighting','phong');
            material('metal');
            hold(hAxes,'on');
        end 
        function hVec=axesSetPropRegTubeFunc(self,hAxes,axesName,projSpecDimVec,varargin)
            import modgen.common.type.simple.checkgen;
            import gras.ellapx.smartdb.RelDispConfigurator;
            set(hAxes,'PlotBoxAspectRatio',[3 1 1]);
            hVec=self.axesSetPropBasic(hAxes,axesName,projSpecDimVec,varargin{:});
        end        
    end
    methods (Access=protected)
        function checkTouchCurves(self,fullRel)
            import gras.ellapx.enums.EProjType;
            TIGHT_PROJ_TOL=1e-15;
            self.checkTouchCurveVsQNormArray(fullRel,fullRel,...
                @(x)max(x-1),...
                ['any touch line''s projection should be within ',...
                'its tube projection'],@(x,y)x==y);
            isTightDynamicVec=...
                (fullRel.lsGoodDirNorm>=1-TIGHT_PROJ_TOL)&...
                (fullRel.projType==EProjType.DynamicAlongGoodCurve);
            rel=fullRel.getTuples(isTightDynamicVec);
            self.checkTouchCurveVsQNormArray(rel,rel,...
                @(x)abs(x-1),...
                ['for dynamic tight projections touch line should be ',...
                'on the boundary of tube''s projection'],...
                @(x,y)x==y);
        end
        function checkDataConsistency(self)
            import modgen.common.throwerror;
            import gras.gen.SquareMatVector;
            %
            checkDataConsistency@gras.ellapx.smartdb.rels.EllTubeBasic(self);
            checkDataConsistency@gras.ellapx.smartdb.rels.EllTubeTouchCurveProjBasic(self);
            if self.getNTuples()>0
                checkFieldList={'dim',...
                        'projSpecDimVec','projType','ltGoodDirNormOrigVec',...
                        'lsGoodDirNormOrig','lsGoodDirOrigVec','timeVec'};
                %
                [isOkList,errTagList,reasonList]=...
                    self.applyTupleGetFunc(@checkTuple,checkFieldList,...
                    'UniformOutput',false);
                %
                isOkVec=vertcat(isOkList{:});
                if ~all(isOkVec)
                    indFirst=find(~isOkVec,1,'first');
                    errTag=errTagList{indFirst};
                    reasonStr=reasonList{indFirst};
                    throwerror(['wrongInput:',errTag],...
                        ['Tuples with indices %s have inconsistent ',...
                        'values, reason: ',reasonStr],...
                        mat2str(find(~isOkVec)));
                end
            end
            function [isOk,errTagStr,reasonStr]=checkTuple(dim,...
                    projSDimVec,projType,ltGoodDirNormOrigVec,...
                    lsGoodDirNormOrig,lsGoodDirOrigVec,timeVec)
                     errTagStr='';
                     import modgen.common.type.simple.lib.*;
                reasonStr='';
                nDims=dim;
                nFDims=length(lsGoodDirOrigVec);
                nPoints=length(timeVec);
                isOk=isrow(projSDimVec)&&numel(projSDimVec)==nFDims&&...
                    numel(projType)==1&&...
                    isrow(ltGoodDirNormOrigVec)&&...
                    numel(ltGoodDirNormOrigVec)==nPoints&&...
                    iscol(lsGoodDirOrigVec)&&...
                    numel(lsGoodDirNormOrig)==1&&...
                    sum(projSDimVec)==nDims;
                if ~isOk
                    reasonStr='Fields have inconsistent sizes';
                    errTagStr='badSize';
                end
            end
        end
    end
    methods
        function plObj=plot(self,plObj)
            % PLOT displays ellipsoidal tubes using the specified
            % RelationDataPlotter
            %
            % Input:
            %   regular:
            %       self:
            %       plObj: smartdb.disp.RelationDataPlotter[1,1] - plotter
            %           object used for displaying ellipsoidal tubes
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-29 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2011 $
            %
            import gras.ellapx.smartdb.rels.EllTubeProjBasic;
            import modgen.logging.log4j.Log4jConfigurator;
            if self.getNTuples()>0
                if nargin<2
                    plObj=smartdb.disp.RelationDataPlotter;
                end
                %
                fGetReachGroupKey=...
                    @(varargin)figureGetNamedGroupKeyFunc(self,...
                    'reachTube',varargin{:});
                fGetRegGroupKey=...
                    @(varargin)figureGetNamedGroupKeyFunc(self,...
                    'regTube',varargin{:});
                %
                fSetReachFigProp=@(varargin)figureNamedSetPropFunc(self,...
                    'reachTube',varargin{:});
                fSetRegFigProp=@(varargin)figureNamedSetPropFunc(self,...
                    'regTube',varargin{:});
                
                %
                fGetTubeAxisKey=@(varargin)axesGetKeyTubeFunc(self,varargin{:});
                fGetCurveAxisKey=@(varargin)axesGetKeyGoodCurveFunc(self,varargin{:});
                %
                fSetTubeAxisProp=@(varargin)axesSetPropTubeFunc(self,varargin{:});
                fSetCurveAxisProp=@(varargin)axesSetPropGoodCurveFunc(self,...
                    varargin{:});
                fSetRegTubeAxisProp=@(varargin)axesSetPropRegTubeFunc(self,varargin{:});
                %
                fPlotReachTube=@(varargin)plotCreateReachTubeFunc(self,varargin{:});
                fPlotRegTube=@(varargin)plotCreateRegTubeFunc(self,varargin{:});
                fPlotCurve=@(varargin)plotCreateGoodDirFunc(self,varargin{:});
                %
                plObj.plotGeneric(self,...
                    {fGetReachGroupKey,fGetReachGroupKey,fGetRegGroupKey},...
                    {'projType','projSpecDimVec','sTime','lsGoodDirOrigVec'},...
                    {fSetReachFigProp,fSetReachFigProp,fSetRegFigProp},...
                    {'projType','projSpecDimVec','sTime'},...
                    {fGetTubeAxisKey,fGetCurveAxisKey,fGetTubeAxisKey},...
                    {'projType','projSpecDimVec'},...
                    {fSetTubeAxisProp,fSetCurveAxisProp,fSetRegTubeAxisProp},...
                    {'projSpecDimVec'},...
                    {fPlotReachTube,fPlotCurve,fPlotRegTube},...
                    {'projType','timeVec','lsGoodDirOrigVec',...
                    'ltGoodDirMat','sTime','xTouchCurveMat',...
                    'xTouchOpCurveMat','ltGoodDirNormVec',...
                    'ltGoodDirNormOrigVec','approxType','QArray','aMat','MArray'});
            else
                logger=Log4jConfigurator.getLogger();
                logger.warn('nTuples=0, there is nothing to plot');
            end
        end
    end
end