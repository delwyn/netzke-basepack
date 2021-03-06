module Netzke
  module Basepack
    class GridPanel < Netzke::Base
      class RecordFormWindow < Window
        js_properties :button_align => "right"

        config :modal => true,
              :width => "50%",
              :auto_height => true,
              :fbar => [:ok.action, :cancel.action]

        action :ok, :text => 'OK'
        action :cancel

        js_method :init_component, <<-JS
          function(params){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.getNetzkeComponent().on("submitsuccess", function(){this.closeRes = "ok"; this.close();}, this);
          }
        JS

        js_method :on_ok, <<-JS
          function(params){
            this.getNetzkeComponent().onApply();
          }
        JS

        js_method :on_cancel, <<-JS
          function(params){
            this.close();
          }
        JS
      end
    end
  end
end