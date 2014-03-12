classdef PTKTabPanel < PTKPanel
    % PTKTabPanel. Part of the gui for the Pulmonary Toolkit.
    %
    %     This class is used internally within the Pulmonary Toolkit to help
    %     build the user interface.
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. http://code.google.com/p/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %    
    
    properties
        FontSize
        FontColour
        TabHeight
    end

    properties (Access = protected)
        OrderedTabs
        Tabs
        TabControl
    end
    
    properties (Constant, Access = private)
        LeftMargin = 10
        RightMargin = 10
        TabSpacing = 10
        BottomMargin = 10;
        TopMargin = 10;
    end
    
    properties (Access = private)
        TextClickedListeners
        BlankText
    end
            

    methods
        function obj = PTKTabPanel(tab_control, reporting)
            obj = obj@PTKPanel(tab_control, reporting);
            obj.TabControl = tab_control;
            obj.FontSize = 20;
            obj.TabHeight = 30;
            obj.FontColour = [1 1 1];
            obj.Tabs = containers.Map;
            
            obj.BlankText = PTKText(obj, '', '', 'blank');
            obj.BlankText.Clickable = false;
            obj.AddChild(obj.BlankText);
            
            obj.OrderedTabs = {};
        end
        
        function delete(obj)
            delete(obj.TextClickedListeners);
        end
        
        function AddTab(obj, name, tag, tooltip)
            tab_text_control = PTKText(obj, name, tooltip, tag);
            tab_text_control.FontColour = PTKSoftwareInfo.TextSecondaryColour;
            tab_text_control.FontSize = obj.FontSize;
            tab_text_control.HorizontalAlignment = 'center';
            obj.AddChild(tab_text_control);
            obj.Tabs(tag) = tab_text_control;
            obj.OrderedTabs{end + 1} = tag;
            
            if isempty(obj.TextClickedListeners)
                obj.TextClickedListeners = addlistener(tab_text_control, 'TextClicked', @obj.TabClicked);
            else
                obj.TextClickedListeners(end + 1) = addlistener(tab_text_control, 'TextClicked', @obj.TabClicked);
            end

        end
        
        function height = GetRequestedHeight(obj, width)            
            height = obj.TopMargin + obj.BottomMargin + obj.TabHeight;
        end
        
        function Resize(obj, panel_position)
            Resize@PTKPanel(obj, panel_position);
            
            number_of_tabs = double(obj.Tabs.Count);
            number_of_enabled_tabs = obj.GetNumberOfEnabledTabs;
            tab_width = (panel_position(3) - obj.LeftMargin - obj.RightMargin - (number_of_tabs - 1)*obj.TabSpacing)/number_of_enabled_tabs;
            tab_height = panel_position(4) - obj.TopMargin - obj.BottomMargin;
            enabled_tab_index = 1;
            for all_tab_index = 1 : number_of_tabs
                tab_tag = obj.OrderedTabs{all_tab_index};
                tab = obj.Tabs(tab_tag);
                if tab.Enabled
                    tab_x = round(obj.LeftMargin + (enabled_tab_index-1)*(tab_width + obj.TabSpacing));
                    tab.Resize([tab_x, obj.BottomMargin, tab_width, tab_height]);
                    enabled_tab_index = enabled_tab_index + 1;
                end
            end
            
            obj.BlankText.Resize([1, 1, panel_position(3), panel_position(4)]);
        end
        
        function number_of_tabs = GetNumberOfEnabledTabs(obj)
            number_of_tabs = 0;
            for tab = obj.Tabs.values
                if tab{1}.Enabled
                    number_of_tabs = number_of_tabs + 1;
                end
            end
        end
        
        function ChangeSelectedTab(obj, tag)
            for tab_key = obj.Tabs.keys
                tab = obj.Tabs(tab_key{1});
                if strcmp(tab_key{1}, tag)
                    tab.Select(true);
                else
                    tab.Select(false);
                end
            end
            obj.TabControl.TabChanged(tag); 
        end
        
        function EnableTab(obj, tag)
            tab = obj.Tabs(tag);
            if ~tab.Enabled
                obj.Resize(obj.Position);
                tab.Enable(obj.Reporting);
            end
            obj.Resize(obj.Position);
        end
        
        function DisableTab(obj, tag)
            tab = obj.Tabs(tag);
            if tab.Enabled
                tab.Disable;
            end
            if ~isempty(obj.Position)
                obj.Resize(obj.Position);
            end
        end
    end
    
    methods (Access = private)
        function TabClicked(obj, ~, tag_data)
            obj.ChangeSelectedTab(tag_data.Data);
        end
    end    
end