# Frontyard
Make it easier to use Phlex views, forms, and components.

Very much work in progress to find some common patterns.

## Usage

TODO…

## Layout components

Frontyard ships layout structure and a small DSL. It ships no CSS: your app
writes the styles and tells the component which class names to use.

### Split

A main column beside a side column, with optional regions after them.

```ruby
render(Frontyard::Split.new) do |split|
  split.split_main { p { "Description" } }
  split.split_side { p { "Intensity" } }          # an <aside>
  split.split_main_after { p { "Under main" } }   # optional
  split.split_foot { p { "Below both" } }         # optional
end
```

- `Split.new(pair: true)` is for a split of only a main and a side. It adds the
  `pair` and `side_pair` class names so your CSS can keep one row.
- Extra keywords (`id:`, `class:`, `data:`, `aria:`) go on the root element,
  and each `split_*` method takes them for its own element.
- The methods keep the `split_` prefix because Phlex already defines `main`
  and `aside` as HTML elements.

Without configuration the classes are `frontyard-split`, `frontyard-split-pair`,
`frontyard-split-main`, `frontyard-split-side`, `frontyard-split-side-pair`,
`frontyard-split-main-after` and `frontyard-split-foot`. To match your own
CSS, subclass and name any of them (the rest keep their defaults, and
subclasses inherit):

```ruby
class Components::UI::Split < Frontyard::Split
  configure_classes root: "split",
    pair: "split-pair",
    main: "split-main",
    side: "split-side",
    side_pair: "split-side-pair",
    main_after: "split-main-after",
    foot: "split-foot"
end
```

`configure_classes` snapshots the parent's names at the moment it is called, so
a parent configured later does not reach a child that is already configured.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "frontyard"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install frontyard
```

## Contributing

## Releasing

This gem uses [Reissue](https://github.com/SOFware/reissue) for versioning and changelog management.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
