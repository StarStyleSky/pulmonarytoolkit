classdef PTKVesselnessDilated < PTKPlugin
    % PTKVesselnessDilated. Creates a vessel mask by thresholding and dilating
    % the output of the vesselness filter
    %
    %     This is a plugin for the Pulmonary Toolkit. Plugins can be run using 
    %     the gui, or through the interfaces provided by the Pulmonary Toolkit.
    %     See PTKPlugin.m for more information on how to run plugins.
    %
    %     Plugins should not be run directly from your code.
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. https://github.com/tomdoel/pulmonarytoolkit
    %     Author: Tom Doel, 2012.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %

    properties
        ButtonText = 'Dilated Vessels'
        ToolTip = 'Shows a blood vessel mask generated by thresholding and dilating the vesselness filter output'
        Category = 'Vessels'
        AllowResultsToBeCached = true
        AlwaysRunPlugin = false
        PluginType = 'ReplaceOverlay'
        HidePluginInDisplay = false
        FlattenPreviewImage = false
        PTKVersion = '1'
        ButtonWidth = 6
        ButtonHeight = 2
        GeneratePreview = true
        Visibility = 'Developer'
    end
    
    methods (Static)
        
        function results = RunPlugin(dataset, reporting)
            results = dataset.GetResult('PTKVesselness');            
            vesselness_raw = results.RawImage >= 5;
            results.ChangeRawImage(vesselness_raw);
            results.ImageType = PTKImageType.Colormap;
            results.BinaryMorph(@imdilate, 4);

        end
        
        function results = GenerateImageFromResults(results, ~, ~)
        end        
        
    end
end