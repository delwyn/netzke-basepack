require "netzke/basepack/grid_panel/columns"
require "netzke/basepack/grid_panel/services"
# require "netzke/basepack/plugins/configuration_tool"

module Netzke
  module Basepack
    # Ext.grid.EditorGridPanel-based component with the following features:
    #
    # * ActiveRecord-model support with automatic column configuration
    # * multi-line CRUD operations - get, post, delete, create
    # * (multe-record) editing and adding records through a form
    # * persistent column resize, move and hide
    # * permissions
    # * sorting
    # * pagination
    # * filtering
    # * advanced search
    # * rows reordering by drag-n-drop, requires acts_as_list on the model
    # * virtual attribute support
    # * (TODO) dynamic configuration of properties and columns
    #
    # == Instance configuration
    # The following config options are supported:
    # * +model+ - name of the ActiveRecord model that provides data to this GridPanel, e.g. "User"
    # * +columns+ - an array of columns to be displayed in the grid; each column may be represented by a symbol (representing the model's attribute name), or a hash (when extra configuration is needed). See the "Columns" section below.
    # * +scope+ - specifies how the data should be filtered.
    #   When it's a symbol, it's used as a scope name.
    #   When it's a string, it's a SQL statement (passed directly to +where+).
    #   When it's a hash, it's a conditions hash (passed directly to +where+).
    #   When it's an array, it's expanded into an SQL statement with arguments (passed directly to +where+), e.g.:
    #
    #     :scope => ["id > ?", 100])
    #
    #   When it's a Proc, it's passed the model class, and is expected to return a ActiveRecord::Relation, e.g.:
    #
    #     :scope => { |rel| rel.where(:id.gt => 100).order(:created_at) }
    #
    # * +strong_default_attrs+ - (defaults to {}) a hash of attributes to be merged atop of every created/updated record, e.g. {:role_id => 1}
    # * +enable_column_filters+ - (defaults to true) enable filters in column's context menu
    # * +enable_edit_in_form+ - (defaults to true) provide buttons into the toolbar that activate editing/adding records via a form
    # * +enable_extended_search+ - (defaults to true) provide a button into the toolbar that shows configurable search form
    # * +enable_context_menu+ - (defaults to true) enable rows context menu
    # * +enable_rows_reordering+ - (defaults to false) enable reordering of rows with drag-n-drop; underlying model (specified in +model+) must implement "acts_as_list"-compatible functionality
    # * +enable_pagination+ - (defaults to true) enable pagination
    # * +rows_per_page+ - (defaults to 30) number of rows per page (ignored when +enable_pagination+ is set to <tt>false+)
    # * +load_inline_data+ - (defaults to true) load initial data into the grid right after its instantiation
    # * (TODO) +mode+ - when set to +config+, GridPanel loads in configuration mode
    # * +add/edit/multi_edit/search_form_config+ - additional configuration for add/edit/multi_edit/search form panel
    # * +add/edit/multi_edit_form_window_config+ - additional configuration for the window that wrapps up add/edit/multi_edit form panel
    #
    # == Columns
    # Columns are configured by passing an array to the +columns+ option. Each element in the array is either the name of model's (virtual) attribute (in which case the configuration will be fully automatic), or a hash that may contain the following configuration options as keys:
    #
    # * +name+ - name of the column, that may correspond to the model's (virtual) attribute
    # * +read_only+ - a boolean that defines if the cells in the column should be editable
    # * +editable+ - same as +read_only+, but in reverse (takes precedence over +read_only+)
    # * +filterable+ - set to false to disable filtering on this column
    # * +getter+ - a lambda that receives a record as a parameter, and is expected to return a string that will be sent to the cell (can be HTML code), e.g.:
    #
    #     :getter => lambda {|r| [r.first_name, r.last_name].join }

    # * +setter+ - a lambda that receives a record as first parameter, and the value passed from the cell as the second parameter, and is expected to modify the record accordingly, e.g.:
    #
    #     :setter => lambda { |r,v| r.first_name, r.last_name = v.split(" ") }
    #
    # * +sorting_scope+ - the name of the scope used for sorting the column. This can be useful for virtual columns for example. The scope will get one parameter specifying the direction (:asc or :desc). Example:
    #
    #     columns => [{ :name => "complete_user_name", :sorting_scope => :sort_user_by_full_name }, ...]
    #
    #     class User < ActiveRecord::Base
    #       scope :sort_user_by_full_name, lambda { |dir|
    #         order("users.first_name #{dir.to_s}, users.last_name #{dir.to_s}")
    #       }
    #     end
    #
    # Besides these options, a column can receive any meaningful config option understood by Ext.grid.Column (http://dev.sencha.com/deploy/dev/docs/?class=Ext.grid.Column)
    #
    # == Actions
    # You can override GridPanel's actions to change their text, icons, and tooltips (see http://api.netzke.org/core/Netzke/Actions.html).
    #
    # GridPanel implements the following actions:
    # * +add+ - inline adding of a record
    # * +del+ - deletion of records
    # * +edit+ - inline editing of a record
    # * +apply+ - applying inline changes
    # * +add_in_form+ - adding a record in a form
    # * +edit_in_form+ - (multi-record) editing in a forrm
    # * +search+ - advanced searching
    #
    # == Class configuration
    #
    # Configuration on this level is effective during the life-time of the application. One place for setting these options are in application.rb, e.g.:
    #
    #     config.netzke.basepack.grid_panel.column_filters_available = false
    #
    # These can also be eventually set directly on the component's class:
    #
    #     Netzke::Basepack::GridPanel.column_filters_available = false
    #
    # Most of these options influence the amount of JavaScript code that is generated for this component's class, in the way that the less functionality is enabled, the less code is generated.
    #
    # The following class configuration options are available:
    # * +column_filters_available+ - (defaults to true) include code for the filters in the column's context menu
    # * (TODO)+config_tool_available+ - (defaults to true) include code for the configuration tool that launches the configuration panel
    # * +edit_in_form_available+ - (defaults to true) include code for (multi-record) editing and adding records through a form
    # * +extended_search_available+ - (defaults to true) include code for extended configurable search
    class GridPanel < Netzke::Base
      js_base_class "Ext.grid.EditorGridPanel"

      # Class-level configuration. These options directly influence the amount of generated
      # javascript code for this component's class. For example, if you don't want filters for the grid,
      # set column_filters_available to false, and the javascript for the filters won't be included at all.
      class_config_option :column_filters_available, true

      class_config_option :extended_search_available, true

      class_config_option :edit_in_form_available, true

      class_config_option :rows_reordering_available, true

      class_config_option :config_tool_available, true

      class_config_option :default_instance_config, {
        :enable_edit_in_form    => edit_in_form_available,
        :enable_extended_search => extended_search_available,
        :enable_column_filters  => column_filters_available,
        :load_inline_data       => true,
        :enable_rows_reordering => false, # column drag n drop
        :enable_pagination      => true,
        :rows_per_page          => 30,
        :tools                  => %w{ refresh },
      }

      extend ActiveSupport::Memoizable

      include self::Services
      include self::Columns
      include Netzke::Basepack::DataAccessor

      js_mixin :grid_panel
      js_mixin :advanced_search if extended_search_available
      js_mixin :edit_in_form if edit_in_form_available

      js_translate *%w[are_you_sure confirmation first_text prev_text next_text last_text before_page_text after_page_text empty_msg refresh_text display_msg]

      # JavaScript includes
      ex = Netzke::Core.ext_location.join("examples")

      js_include(ex.join("ux/CheckColumn.js"))

      # Includes for column filters
      if column_filters_available
        [
          "ux/gridfilters/menu/ListMenu.js",
          "ux/gridfilters/menu/RangeMenu.js",
          "ux/gridfilters/GridFilters.js"
        ].each{ |path| js_include(ex.join(path)) }

        %w{Boolean Date List Numeric String}.unshift("").each do |f|
          js_include(ex.join"ux/gridfilters/filter/#{f}Filter.js")
        end
      end

      # Includes for rows reordering
      if rows_reordering_available
        js_include(ex.join("#{File.dirname(__FILE__)}/grid_panel/javascripts/rows-dd.js"))
      end

      def js_config
        super.merge({
          :bbar => config.has_key?(:bbar) ? config[:bbar] : default_bbar,
          :context_menu => config.has_key?(:context_menu) ? config[:context_menu] : default_context_menu,
          :columns => columns(:with_meta => true), # columns
          :columns_order => config[:persistence] && state[:columns_order] || initial_columns_order,
          :model => config[:model], # the model name
          :inline_data => (get_data if config[:load_inline_data]), # inline data (loaded along with the grid panel)
          :pri => data_class.primary_key # table primary key name
        })
      end

      def get_association_values(record)
        columns.select{ |c| c[:name].index("__") }.each.inject({}) do |r,c|
          r.merge(c[:name] => record.value_for_attribute(c, true))
        end
      end

      def get_default_association_values
        columns.select{ |c| c[:name].index("__") && c[:default_value] }.each.inject({}) do |r,c|
          assoc, assoc_method = assoc_and_assoc_method_for_column(c)
          assoc_instance = assoc.klass.find(c[:default_value])
          r.merge(c[:name] => assoc_instance.send(assoc_method))
        end
      end
      memoize :get_default_association_values

      def default_bbar
        res = %w{ add edit apply del }.map(&:to_sym).map(&:action)
        res << "-" << :add_in_form.action << :edit_in_form.action if config[:enable_edit_in_form]
        res << "-" << :search.action if config[:enable_extended_search]
        res << "-" << :export.action if config[:enable_export]
        res
      end

      def default_context_menu
        res = %w{ edit del }.map(&:to_sym).map(&:action)
        res << "-" << :edit_in_form.action if config[:enable_edit_in_form]
        res
      end

      def configuration_components
        res = []
        res << {
          :persistent_config => true,
          :name              => 'columns',
          :class_name        => "FieldsConfigurator",
          :active            => true,
          :owner             => self
        }
        res << {
          :name               => 'general',
          :class_name  => "PropertyEditor",
          :component             => self,
          :title => false
        }
        res
      end

      action :add do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.add'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.add'),
          :disabled => config[:prohibit_create],
          :icon => :add
        }
      end

      action :edit do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.edit'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.edit'),
          :disabled => true,
          :icon => :table_edit
        }
      end

      action :del do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.del'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.del'),
          :disabled => true,
          :icon => :table_row_delete
        }
      end

      action :apply do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.apply'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.apply'),
          :disabled => config[:prohibit_update] && config[:prohibit_create],
          :icon => :tick
        }
      end

      action :add_in_form do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.add_in_form'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.add_in_form'),
          :icon => :application_form_add
        }
      end

      action :edit_in_form do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.edit_in_form'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.edit_in_form'),
          :disabled => true,
          :icon => :application_form_edit
        }
      end

      action :search do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.search'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.search'),
          :enable_toggle => true,
          :icon => :find
        }
      end
      
      action :export do
        {
          :text => I18n.t('netzke.basepack.grid_panel.actions.export'),
          :tooltip => I18n.t('netzke.basepack.grid_panel.actions.export'),
          :icon => :page_excel
        }
      end

      component :add_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::GridPanel::RecordFormWindow",
          :title => "Add #{data_class.model_name.human}",
          :button_align => "right",
          :items => [{
            :class_name => "Netzke::Basepack::FormPanel",
            :model => config[:model],
            :items => default_fields_for_forms,
            :persistent_config => config[:persistent_config],
            :strong_default_attrs => config[:strong_default_attrs],
            :border => true,
            :bbar => false,
            :header => false,
            :mode => config[:mode],
            :record => data_class.new(columns_default_values)
          }.deep_merge(config[:add_form_config] || {})]
        }.deep_merge(config[:add_form_window_config] || {})
      end

      component :edit_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::GridPanel::RecordFormWindow",
          :title => "Edit #{data_class.model_name.human}",
          :button_align => "right",
          :items => [{
            :class_name => "Netzke::Basepack::FormPanel",
            :model => config[:model],
            :items => default_fields_for_forms,
            :persistent_config => config[:persistent_config],
            :bbar => false,
            :header => false,
            :mode => config[:mode]
            # :record_id gets assigned by deliver_component dynamically, at the moment of loading
          }.deep_merge(config[:edit_form_config] || {})]
        }.deep_merge(config[:edit_form_window_config] || {})
      end

      component :multi_edit_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::GridPanel::RecordFormWindow",
          :title => "Edit #{data_class.model_name.human.pluralize}",
          :button_align => "right",
          :items => [{
            :class_name => "Netzke::Basepack::GridPanel::MultiEditForm",
            :model => config[:model],
            :items => default_fields_for_forms,
            :persistent_config => config[:persistent_config],
            :bbar => false,
            :header => false,
            :mode => config[:mode]
          }.deep_merge(config[:multi_edit_form_config] || {})]
        }.deep_merge(config[:multi_edit_form_window_config] || {})
      end

      component :search_form do
        {
          :lazy_loading => true,
          :class_name => "Netzke::Basepack::SearchWindow",
          :model => config[:model],
          :fields => default_fields_for_forms
        }
      end

      # include ::Netzke::Plugins::ConfigurationTool if config_tool_available # it will load ConfigurationPanel into a modal window

    end
  end
end
