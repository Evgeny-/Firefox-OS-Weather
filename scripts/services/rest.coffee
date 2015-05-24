App.service 'Rest', ['$resource', class
  restUrl = 'http://api.worldweatheronline.com/free/v1/'

  resourceOptions =
    get:
      method: 'JSONP'
      params: callback: 'JSON_CALLBACK'

  defaultQuery =
    num_of_results: 5
    key: 'xqxeawkvwdcbrqr7qxtdhxp2'
    format: 'json'
    num_of_days: 5
    lang: LANG

  constructor: ($resource) ->
    @rest = {}
    @rest.weather = $resource restUrl + 'weather.ashx', defaultQuery, resourceOptions
    @rest.city = $resource restUrl + 'search.ashx', defaultQuery, resourceOptions

  getCityByGeoLocation: (lat, lon, callback=angular.noop) ->
    @rest.city.get {q: "#{lat},#{lon}"}, callback

  getCity: (city, callback=angular.noop) ->
    @rest.city.get {q: city}, callback

  getWeather: (cityName, callback=angular.noop) ->
    console.log cityName
    @rest.weather.get {q: cityName}, callback
]