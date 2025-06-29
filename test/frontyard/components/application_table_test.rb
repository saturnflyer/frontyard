require "test_helper"

class TestTable < Frontyard::ApplicationTable
  class Row < Phlex::HTML
    def initialize(**kwargs)
      @data = kwargs[:data]
      @id = kwargs[:id]
      @class_name = kwargs[:class]
      super()
    end

    def view_template
      tr(id: @id, class: @class_name) { td { @data } }
    end
  end
end

class TestTableWithoutRow < Frontyard::ApplicationTable
  # This table doesn't define a Row class
end

describe Frontyard::ApplicationTable do
  describe "#render_row" do
    it "renders a row using the table's Row class" do
      table = TestTable.new
      
      # Mock the render method to capture what would be rendered
      rendered_component = nil
      table.define_singleton_method(:render) do |component|
        rendered_component = component
        ""
      end
      
      table.render_row(data: "test data")
      
      assert_instance_of TestTable::Row, rendered_component
      assert_equal "test data", rendered_component.instance_variable_get(:@data)
    end

    it "passes all arguments to the Row component" do
      table = TestTable.new
      
      rendered_component = nil
      table.define_singleton_method(:render) do |component|
        rendered_component = component
        ""
      end
      
      table.render_row(data: "test", id: 123, class: "row-class")
      
      assert_instance_of TestTable::Row, rendered_component
      assert_equal "test", rendered_component.instance_variable_get(:@data)
      assert_equal 123, rendered_component.instance_variable_get(:@id)
      assert_equal "row-class", rendered_component.instance_variable_get(:@class_name)
    end

    it "raises an error when Row class is not defined" do
      table = TestTableWithoutRow.new
      
      error = assert_raises(NoMethodError) do
        table.render_row(data: "test")
      end
      
      # Handle both single quote and backtick formats in error messages
      assert_includes error.message, "undefined method"
      assert_includes error.message, "buffer"
      assert_includes error.message, "nil"
    end

    it "works with different data types" do
      table = TestTable.new
      
      rendered_component = nil
      table.define_singleton_method(:render) do |component|
        rendered_component = component
        ""
      end
      
      # Test with string
      table.render_row(data: "string data")
      assert_equal "string data", rendered_component.instance_variable_get(:@data)
      
      # Test with number
      table.render_row(data: 42)
      assert_equal 42, rendered_component.instance_variable_get(:@data)
      
      # Test with hash
      table.render_row(data: { key: "value" })
      assert_equal({ key: "value" }, rendered_component.instance_variable_get(:@data))
    end
  end

  describe "inheritance" do
    it "inherits from ApplicationComponent" do
      assert Frontyard::ApplicationTable < Frontyard::ApplicationComponent
    end

    it "can be instantiated" do
      table = TestTable.new
      assert_instance_of TestTable, table
    end
  end

  describe "integration" do
    it "can render a complete table with rows" do
      class CompleteTable < Frontyard::ApplicationTable
        class Row < Phlex::HTML
          def initialize(data:)
            @data = data
            super()
          end

          def view_template
            tr do
              td { @data[:name] }
              td { @data[:age].to_s }
            end
          end
        end

        def view_template
          super do
            table do
              thead do
                tr do
                  th { "Name" }
                  th { "Age" }
                end
              end
              tbody do
                render_row(data: { name: "John", age: 30 })
                render_row(data: { name: "Jane", age: 25 })
              end
            end
          end
        end
      end

      table = CompleteTable.new
      buffer = TestBuffer.new
      table.call(buffer)
      result = buffer.to_s

      assert_includes result, '<table>'
      assert_includes result, '<thead>'
      assert_includes result, '<tbody>'
      assert_includes result, 'John'
      assert_includes result, 'Jane'
      assert_includes result, '30'
      assert_includes result, '25'
    end
  end
end 
