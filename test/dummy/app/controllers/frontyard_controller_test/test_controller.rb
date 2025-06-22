# frozen_string_literal: true

module FrontyardControllerTest
  class TestController < ApplicationController
    def index
      render_view
    end

    def show
      render_view
    end

    def new
      render_view
    end

    def edit
      render_view
    end

    def create
      render_view
    end

    def update
      render_view
    end

    def destroy
      render_view
    end

    private

    def test_resource
      resource = Object.new
      resource.define_singleton_method(:id) { 1 }
      resource.define_singleton_method(:name) { "Test Resource" }
      resource
    end

    def test_collection
      item1 = Object.new
      item1.define_singleton_method(:id) { 1 }
      item1.define_singleton_method(:name) { "Item 1" }
      
      item2 = Object.new
      item2.define_singleton_method(:id) { 2 }
      item2.define_singleton_method(:name) { "Item 2" }
      
      [item1, item2]
    end
  end
end 
