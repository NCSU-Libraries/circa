# ng-country-select

[![Build Status](https://travis-ci.org/navinpeiris/ng-country-select.svg?branch=master)](https://travis-ci.org/navinpeiris/ng-country-select)

Angular module to generate an HTML select list of countries using country codes in the
[ISO 3166-1 standard](https://en.wikipedia.org/wiki/ISO_3166-1).

Closely resembles the behaviour of the [country_select](https://github.com/stefanpenner/country_select) ruby gem.

## Install

You can install this package either with `npm` or with `bower`.

### npm

```shell
npm install ng-country-select
```

Then add the `<script>` to your `index.html`:

```html
<script src="/node_modules/ng-country-select/dist/ng-country-select.js"></script>
```

### bower

```shell
bower install ng-country-select
```

Then add a `<script>` to your `index.html`:

```html
<script src="/bower_components/ng-country-select/dist/ng-country-select.js"></script>
```

## Usage

Add `countrySelect` as a dependency for your app:

```javascript
angular.module('myApp', ['...', 'countrySelect', '...'])
```

Simple usage to get a list of countries:

```html
<country-select></country-select>
```

Supplying priority countries to be placed at the top of the list:

```html
<country-select cs-priorities="AU, DE, GB, US"></country-select>
```

Supplying only certain countries:

```html
<country-select cs-only="AU, DE, GB, US"></country-select>
```

Discarding certain countries:

```html
<country-select cs-except="AU, DE, GB, US"></country-select>
```

Making the selection mandatory by removing the empty option:

```html
<country-select cs-required></country-select>
```

## License

The MIT License

Copyright (c) 2015 Navin Peiris http://navinpeiris.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
