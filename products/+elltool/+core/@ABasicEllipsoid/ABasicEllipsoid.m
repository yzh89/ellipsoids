classdef ABasicEllipsoid < handle
    properties(Access=protected)
        centerVec    
        absTol
    end
    %
    methods (Access = protected)
        function [isEqualArr, reportStr] = isEqualInternal(ellFirstArr,...
                ellSecArr, isPropIncluded)
            import modgen.struct.structcomparevec;
            import gras.la.sqrtmpos;
            import elltool.conf.Properties;
            import modgen.common.throwerror;
            %
            nFirstElems = numel(ellFirstArr);
            nSecElems = numel(ellSecArr);
            if (nFirstElems == 0 && nSecElems == 0)
                isEqualArr = true;
                reportStr = '';
                return;
            elseif (nFirstElems == 0 || nSecElems == 0)
                throwerror('wrongInput:emptyArray',...
                    'input ellipsoidal arrays should be empty at the same time');
            end
            [~, absTol]=ellFirstArr.getAbsTol();
            firstSizeVec = size(ellFirstArr);
            secSizeVec = size(ellSecArr);
            isnFirstScalar=nFirstElems > 1;
            isnSecScalar=nSecElems > 1;
            [SEll1Array, SFieldNiceNames, ~] = ...
                ellFirstArr.toStruct(isPropIncluded);
            SEll2Array = ellSecArr.toStruct(isPropIncluded);
            %
            SEll1Array = arrayfun(@(SEll)ellFirstArr.formCompStruct(SEll,...
                SFieldNiceNames, absTol, isPropIncluded), SEll1Array);
            SEll2Array = arrayfun(@(SEll)ellSecArr.formCompStruct(SEll,...
                SFieldNiceNames, absTol, isPropIncluded), SEll2Array);
            if isnFirstScalar&&isnSecScalar
                if ~isequal(firstSizeVec, secSizeVec)
                    throwerror('wrongSizes',...
                        'sizes of ellipsoidal arrays do not... match');
                end;
                compare();
                isEqualArr = reshape(isEqualArr, firstSizeVec);
            elseif isnFirstScalar
                SEll2Array=repmat(SEll2Array, firstSizeVec);
                compare();
                
                isEqualArr = reshape(isEqualArr, firstSizeVec);
            else
                SEll1Array=repmat(SEll1Array, secSizeVec);
                compare();
                isEqualArr = reshape(isEqualArr, secSizeVec);
            end
            function compare()
                [isEqualArr, reportStr] =...
                    modgen.struct.structcomparevec(SEll1Array,...
                    SEll2Array, absTol);
            end
        end
        %
        polar=getScalarPolarInternal(self, isRobustMethod)
        [propArr,propVal]=getProperty(ellArr,propName,fPropFun)
    end
    methods (Static)
        checkIsMeInternal(objType,ellArr,varargin)
    end
    methods (Access=protected,Abstract)
        checkIsMeVirtual(ellArr,varargin)
        copyEllObj=getSingleCopy(ellObj)
        ellObj=ellFactory(self)
    end
    methods 
        [absTolArr, absTolVal]=getAbsTol(ellArr, varargin)
        copyEllArr=getCopy(ellArr)
        isPositiveArr=isEmpty(myEllArr)
    end
end