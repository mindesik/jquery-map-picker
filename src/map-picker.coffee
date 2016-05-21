# Map picker class
# @param object container [Selector for map]
# @param object config [Configuration object]

class MapPicker
    constructor: (@container, @config) ->
        @geocoder = new (google.maps.Geocoder)
        @address = []
        
        delete @config.center if isNaN(@config.center.lat) or isNaN(@config.center.lng)
        
        @defaultConfig =
            center:
                lat: 55.7494733
                lng: 37.3523241
            zoom: 4
            
        $.extend @defaultConfig, @config if @config
        
        do @init

    # Define callback function for use button click
    # @param function callback [callback function]
    # @return MapPicker [return self for method chaining]

    use: (@useCb) -> @

    # Define callback function for cancel button click
    # @param function callback [callback function]
    # @return MapPicker [return self for method chaining]

    cancel: (@cancelCb) -> @

    # Initialize map object
    # @return void

    init: ->
        # Initialize google maps
        @map = new (google.maps.Map)(@container.find('.map').get(0), @config)
        @map.addListener 'click', (event) =>
            @setMarker event.latLng
        
        @addSearchBox()
        
        if @config.lat != 0 and @config.lng != 0
            @setMarker @config.center
        
        # Listen for button clicks
        @container.on 'click', '.map-use', =>
            @useCb @address, @marker.position.toJSON() if @useCb
        
        @container.on 'click', '.map-close', =>
            do @cancelCb if @cancelCb

    # Add search box input to map
    # @return void

    addSearchBox: ->
        input = document.getElementById('pac-input')
        searchBox = new (google.maps.places.SearchBox)(input)
        @map.controls[google.maps.ControlPosition.TOP_LEFT].push input
        searchBox.setBounds @map.getBounds()
        
        @map.addListener 'bounds_changed', =>
            searchBox.setBounds @map.getBounds()
        
        searchBox.addListener 'places_changed', =>
            places = searchBox.getPlaces()
            return if places.length is 0
            
            bounds = new (google.maps.LatLngBounds)
            
            places.forEach (place) =>
                icon = 
                    url: place.icon
                    size: new (google.maps.Size)(71, 71)
                    origin: new (google.maps.Point)(0, 0)
                    anchor: new (google.maps.Point)(17, 34)
                    scaledSize: new (google.maps.Size)(25, 25)
                @setMarker place.geometry.location
                if place.geometry.viewport
                    # Only geocodes have viewport.
                    bounds.union place.geometry.viewport
                else
                    bounds.extend place.geometry.location
            
            @map.fitBounds bounds

    # Add marker on map when clicked
    # @param LatLng location
    # @return void

    setMarker: (location) ->
        @marker.setMap null if @marker
        
        @marker = new (google.maps.Marker)(
            position: location
            map: @map)
        
        @geocode location
        
        @marker.setMap @map

    # Convert geolocation to address
    # @param    LatLng location
    # @return void

    geocode: (location) ->
        @container.block
            message: null
            overlayCSS: opacity: 0
        
        @geocoder.geocode { 'location': location }, (results, status) =>
            @address = []
            if status == google.maps.GeocoderStatus.OK
                if results.length > 0
                    @address.push
                        type: 'formatted_address'
                        long_name: results[0]['formatted_address']
                    for i of results[0]['address_components']
                        place = results[0]['address_components'][i]
                        type = place['types'][0]
                        @address.push
                            type: type
                            long_name: place.long_name
                            short_name: place.short_name
            @container.unblock()
            @fillAddressCard()

    # Fill address card
    # @return void

    fillAddressCard: ->
        $container = @container.find('.map-address')
        if @address.length == 0
            $container.html 'No address info found at selected location.'
        else
            $container.html ''
            for i of @address
                place = @address[i]
                label = place.type.charAt(0).toUpperCase() + place.type.slice(1).split('_').join(' ')
                short_name = if place.short_name then ' (' + place.short_name + ')' else ''
                $container.append $('<address><strong>' + label + '</strong> (' + place.type + ')<br>' + place.long_name + short_name + '</address>')
        @toggleControls()

    # Show or hide use and cancel buttons
    # @return void

    toggleControls: ->
        if @address.length is 0
            @container.find('.map-use-controls').addClass 'hide'
        else
            @container.find('.map-use-controls').removeClass 'hide'

# jQuery plugin call
# @param object config [Configuration object]
# @return void

$.fn.mapPicker = (config) -> new MapPicker(this, config)