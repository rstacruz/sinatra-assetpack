v0.0.6 - Aug 30, 2011
---------------------

### Fixed:
  * Redundant entries are now suppressed. (eg, when specifying 
      `['vendor/jquery.js', 'vendor/*.js']`)

### Added:
  * Allow a parameter to the block in the `assets` configuration block.
  * Update README with lots of info.
  * Allow multiple packages in the js and css helpers. (eg, `css :base, :login`)
  * Allow setting options for `js_compression` by passing a hash after it.
  * Make the path parameter in `js` and `css` in the `assets` block optional.

v0.0.5 - Aug 30, 2011
---------------------

### Fixed:
  * Fix build failing when it finds directories.

### Added:
  * Added an example app in `example/`.

v0.0.4 - Aug 30, 2011
---------------------

### Fixed:
  * Ruby 1.8 compatibility. Yay!
  * Fixed images always being square.
  * Assets are now ordered properly.

### Changed:
  * the config format for `js_compression` and family. In your `assets` block, 
  you now have to use `js_compression :closure` instead of `js_compression = 
  :closure`.
  * Use simple CSS compression by default.

v0.0.3 - Aug 30, 2011
---------------------

### Added:
  * Images in CSS defined in `url(...)` params are now cache-busted.
  * Add support for embedded images in CSS.
  * `rake assetpack:build` now also outputs images.

v0.0.2 - Aug 29, 2011
---------------------

### Added:
  * Added the `img` helper.
  * Added support for filetypes used in @font-face.

### Fixed:
  * The gem now installs the correct dependencies.

v0.0.1 - Aug 29, 2011
---------------------

Initial release.
