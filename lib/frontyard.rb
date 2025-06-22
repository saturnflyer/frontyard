require_relative "frontyard/version"
require_relative "frontyard/engine"
require "contours"

module Frontyard
  extend Phlex::Kit

  class Config < Contours::BlendedHash
    @blended_keys = [:class]
    blend :class, with: Contours::StructuredString
  end
end
