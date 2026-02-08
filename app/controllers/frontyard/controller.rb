module Frontyard
  module Controller
    extend ActiveSupport::Concern

    included do
      layout -> { _resolve_frontyard_layout }
    end

    class_methods do
      # Set an explicit Phlex layout class for this controller.
      #
      #   frontyard_layout Views::Layouts::AdminLayout
      #   frontyard_layout false  # disable Phlex layout
      def frontyard_layout(klass = :__unset__)
        if klass == :__unset__
          if defined?(@_frontyard_layout)
            @_frontyard_layout
          elsif superclass.respond_to?(:frontyard_layout)
            superclass.frontyard_layout
          end
        else
          @_frontyard_layout = klass
        end
      end
    end

    # Get the form class for the current controller
    def form
      namespace = controller_name.camelize
      ::Views.const_get("#{namespace}::Form")
    end

    def form_params
      form.process_params(params)
    end

    def render_view(action_name: self.action_name, **kwargs)
      klass = "views/#{controller_name}/#{action_name}".classify.constantize
      # Get the initialize parameters from the view class
      init_params = klass.instance_method(:initialize).parameters
      # Symbolize all keys in kwargs
      symbolized_kwargs = kwargs.transform_keys(&:to_sym)
      # Start with kwargs, but fill in required params from controller if missing
      view_data = {}
      init_params.each do |type, name|
        sym_name = name.to_sym
        if symbolized_kwargs.key?(sym_name)
          # Parameter was provided in kwargs
          view_data[sym_name] = symbolized_kwargs[sym_name]
        elsif type == :keyreq && respond_to?(name, true)
          # Required parameter not provided, call controller method
          view_data[sym_name] = send(name)
        elsif type == :key && respond_to?(name, true)
          # Optional parameter not provided, call controller method
          view_data[sym_name] = send(name)
        end
      end
      view_data[:flash] = flash
      render_data = symbolized_kwargs.except(*view_data.keys)
      render klass.new(**view_data), **render_data
    end

    private

    def _resolve_frontyard_layout
      # Check for explicit layout set on the controller class
      explicit = self.class.frontyard_layout
      if explicit
        return explicit
      elsif explicit == false
        return nil
      end

      # Convention: look for Views::Layouts::ApplicationLayout
      begin
        Views::Layouts::ApplicationLayout
      rescue NameError
        nil
      end
    end
  end
end
