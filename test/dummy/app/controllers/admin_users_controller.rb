# frozen_string_literal: true

class AdminUsersController < ApplicationController
  def form_test
    form_class = form
    render plain: form_class.name
  end
end 
