classdef MimMemoryCache < handle
    % MimMemoryCache. Part of the internal framework of the Pulmonary Toolkit.
    %
    %     You should not use this class within your own code. It is intended to
    %     be used internally within the framework of the Pulmonary Toolkit.
    %
    %     Used to cache plugin results in memory.
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %        
    
    properties (Access = private)
        MemoryCacheMap
        TemporaryKeys % Keys that will be cleared by ClearTemporaryResults()
    end
    
    methods
        
        function obj = MimMemoryCache(reporting)
            obj.Delete(reporting);
        end
        
        function exists = Exists(obj, name, context, ~)
            exists = obj.MemoryCacheMap.isKey(MimMemoryCache.GetKey(name, context));
        end

        function [result, info] = Load(obj, name, context, reporting)
            % Load a result from the cache
            
            if obj.Exists(name, context, reporting)
                cache_item = obj.MemoryCache(MimMemoryCache.GetKey(name, context));
                result = cache_item.Value;
                if (nargout > 1)
                    info = cache_item.Info;
                end
            else
                result = []; 
                info = [];
             end
        end
        
        function Save(obj, name, value, context, cache_policy, reporting)
            % Save a result to the cache

            obj.Add(name, value, [], context, cache_policy, reporting);
        end

        function SaveWithInfo(obj, name, value, info, context, cache_policy, reporting)
            % Save a result to the cache

            obj.Add(name, value, info, context, cache_policy, reporting);
        end
        
        function Delete(obj, ~)
            % Clears the cache
            
            obj.MemoryCacheMap = containers.Map;
            obj.TemporaryKeys = [];
        end

        function RemoveAllCachedFiles(obj, ~, reporting)
            % Clears the cache
            
            obj.Delete(reporting);
        end
        
        function ClearTemporaryResults(obj)
            for key = obj.TemporaryKeys
                if obj.MemoryCacheMap.isKey(key{1})
                    obj.MemoryCacheMap.remove(key{1});
                end
            end
            obj.TemporaryKeys = [];
        end
    end
    
    methods (Access = private)
        function Add(obj, name, value, info, context, cache_policy, reporting)
            switch cache_policy
                case MimCachePolicy.Off
                    cache = false;
                    is_temporary = false;
                case MimCachePolicy.Temporary
                    cache = true;
                    is_temporary = true;
                case MimCachePolicy.Session
                    cache = true;
                    is_temporary = false;
                case MimCachePolicy.Permanent
                    cache = true;
                    is_temporary = false;
                otherwise
                    reporting.Error('MimMemoryCache:UnknownCachePolicy', 'The memory cache policy was not recognised.');
            end
            
            if cache            
                new_key = MimMemoryCache.GetKey(name, context);
                obj.MemoryCache(new_key) = MimMemoryCacheItem(value, info);
                if is_temporary
                    obj.TemporaryKeys{end + 1} = new_key;
                    obj.TemporaryKeys = unique(obj.TemporaryKeys);
                end
            end
        end        
    end
        
    methods (Static, Access = private)
        function key_name = GetKey(name, context)
            key_name = [char(name) '.' char(context)];
        end
    end
end