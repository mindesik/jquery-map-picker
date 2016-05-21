# Jquery map picker

## Usage

```html
<script src="//js.evmin.ru/build/map-picker.min.js" type="text/javascript"/>
```

```html
<div id="map-picker-container">
    <input id="pac-input" class="controls" type="text" placeholder="Search">
    <div class="map"></div>
    <div class="map-use btn btn-sm blue">Use this place</div>
</div>
```

```javascript
// By default center of the USA is loaded
// But you may pass google maps javascript api options like location or zoom
var picker = $('#map-picker-container').mapPicker(options);

// Callbacks
picker.use(function (address, location) {
    // ...
})

picker.cancel(function () {
    // ...
});

```

## Build

```
$ npm install
$ gulp build
```