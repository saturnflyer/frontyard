module Frontyard
  class ApplicationTable < ApplicationComponent
    def render_row(**kwargs, &block)
      if self.class.const_defined?(:Row)
        render self.class::Row.new(**kwargs, &block)
      else
        tr(**kwargs, &block)
      end
    end
  end
end
