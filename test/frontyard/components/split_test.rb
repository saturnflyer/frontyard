# frozen_string_literal: true

require "test_helper"

class MappedSplit < Frontyard::Split
  configure_classes root: "split", pair: "split-pair", main: "split-main", side: "split-side",
    side_pair: "split-side-pair", main_after: "split-main-after", foot: "split-foot"
end

class PartialSplit < Frontyard::Split
  configure_classes root: "layout"
end

class ChildOfMappedSplit < MappedSplit
end

describe Frontyard::Split do
  def full(split_class, **options)
    split_class.new(**options).call do |split|
      split.split_main { split.p { "Main" } }
      split.split_side { split.p { "Side" } }
      split.split_main_after { split.p { "After" } }
      split.split_foot { split.p { "Foot" } }
    end
  end

  it "renders main, side (an aside), main_after and foot under generic class names" do
    expect(full(Frontyard::Split)).must_equal(
      %(<div class="frontyard-split"><div class="frontyard-split-main"><p>Main</p></div>) +
      %(<aside class="frontyard-split-side"><p>Side</p></aside>) +
      %(<div class="frontyard-split-main-after"><p>After</p></div>) +
      %(<div class="frontyard-split-foot"><p>Foot</p></div></div>)
    )
  end

  it "adds the pair modifiers to the root and the side" do
    html = Frontyard::Split.new(pair: true).call do |split|
      split.split_main { "M" }
      split.split_side { "S" }
    end

    expect(html).must_equal(
      %(<div class="frontyard-split frontyard-split-pair"><div class="frontyard-split-main">M</div>) +
      %(<aside class="frontyard-split-side frontyard-split-side-pair">S</aside></div>)
    )
  end

  it "uses the class names an app configures" do
    expect(full(MappedSplit)).must_equal(
      %(<div class="split"><div class="split-main"><p>Main</p></div><aside class="split-side"><p>Side</p></aside>) +
      %(<div class="split-main-after"><p>After</p></div><div class="split-foot"><p>Foot</p></div></div>)
    )
    expect(MappedSplit.new(pair: true).call { |s| s.split_side { "S" } }).must_equal(
      %(<div class="split split-pair"><aside class="split-side split-side-pair">S</aside></div>)
    )
  end

  it "keeps defaults for names it does not override, and does not leak between classes" do
    expect(PartialSplit.classes[:main]).must_equal "frontyard-split-main"
    expect(PartialSplit.classes[:root]).must_equal "layout"
    expect(Frontyard::Split.classes[:root]).must_equal "frontyard-split"
  end

  it "inherits a parent's configured names" do
    expect(ChildOfMappedSplit.classes[:main]).must_equal "split-main"
  end

  it "rejects unknown class keys" do
    expect { Class.new(Frontyard::Split) { configure_classes sidebar: "x" } }.must_raise ArgumentError
  end

  it "passes attributes through to the root and to each region" do
    html = Frontyard::Split.new(id: "page", class: "extra", data: {controller: "x"}, aria: {label: "Page"}).call do |split|
      split.split_main(id: "m", class: "tall") { "M" }
      split.split_side(data: {role: "side"}) { "S" }
    end

    expect(html).must_include %(<div id="page" class="frontyard-split extra" data-controller="x" aria-label="Page">)
    expect(html).must_include %(<div id="m" class="frontyard-split-main tall">M</div>)
    expect(html).must_include %(<aside data-role="side" class="frontyard-split-side">S</aside>)
  end
end
