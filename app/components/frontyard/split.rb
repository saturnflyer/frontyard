# frozen_string_literal: true

module Frontyard
  # A main column with a side column beside it, plus two optional regions
  # that follow them. Frontyard ships the structure and the DSL; the app
  # supplies the CSS and tells the component which class names to use.
  #
  #   render(Frontyard::Split.new) do |split|
  #     split.split_main { ... }
  #     split.split_side { ... }
  #     split.split_main_after { ... }
  #     split.split_foot { ... }
  #   end
  #
  # The DSL methods keep the `split_` prefix: Phlex already defines `main` and
  # `aside` as HTML elements, and a same-named method would shadow them.
  #
  # It inherits Phlex::HTML, not Frontyard::ApplicationComponent: a layout
  # primitive needs none of that class's route/link helpers or its
  # development-only "Before ..." comment, so adopted markup stays identical.
  #
  # Class names are configured once per class (subclasses inherit and may
  # override):
  #
  #   class AppSplit < Frontyard::Split
  #     configure_classes root: "split", main: "split-main", side: "split-side"
  #   end
  class Split < Phlex::HTML
    DEFAULT_CLASSES = {
      root: "frontyard-split",
      pair: "frontyard-split-pair",
      main: "frontyard-split-main",
      side: "frontyard-split-side",
      side_pair: "frontyard-split-side-pair",
      main_after: "frontyard-split-main-after",
      foot: "frontyard-split-foot"
    }.freeze

    class << self
      # The class names in force: defaults, then each ancestor's overrides.
      def classes
        @classes || (superclass.respond_to?(:classes) ? superclass.classes : DEFAULT_CLASSES)
      end

      # Override some or all class names. Unknown keys raise.
      def configure_classes(**names)
        unknown = names.keys - DEFAULT_CLASSES.keys
        raise ArgumentError, "unknown split class keys: #{unknown.join(", ")}" if unknown.any?

        @classes = classes.merge(names).freeze
      end
    end

    # `pair: true` is for a split of only a main and a side: it keeps the one
    # row, where the full layout's rows for `split_main_after` and
    # `split_foot` would leave their gaps behind with nothing in them.
    #
    # Extra keyword attributes (id, data, aria, class) go on the root element.
    def initialize(pair: false, **attributes)
      @pair = pair
      @attributes = attributes
    end

    def view_template(&) = div(**tag_attributes(:root, (:pair if @pair), @attributes), &)

    def split_main(**attributes, &) = div(**tag_attributes(:main, nil, attributes), &)

    def split_side(**attributes, &)
      aside(**tag_attributes(:side, (:side_pair if @pair), attributes), &)
    end

    # Under the main column on a wide screen, beside a tall side; after the
    # side on a phone.
    def split_main_after(**attributes, &) = div(**tag_attributes(:main_after, nil, attributes), &)

    # Below both columns on a wide screen; after the side on a phone.
    def split_foot(**attributes, &) = div(**tag_attributes(:foot, nil, attributes), &)

    private

    def tag_attributes(key, modifier, attributes)
      configured = [self.class.classes[key], (self.class.classes[modifier] if modifier)].compact_blank.join(" ")
      return attributes if configured.empty?

      mix({class: configured}, attributes)
    end
  end
end
