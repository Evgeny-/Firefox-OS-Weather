App.service 'Storage', [class
  get: (key, json = true) ->
    value = localStorage.getItem key
    unless json then value else JSON.parse value

  set: (key, value) ->
    value = JSON.stringify value if typeof value is 'object'
    localStorage.setItem key, value

  remove: (key) -> @set key, null
]


App.service 'City', ['Storage', class
  constructor: (Storage) ->
    @cities = Storage.get('cities') or []
    @save = -> Storage.set 'cities', @cities.map (city) ->
      delete city['$$hashKey']
      city

  get: (name) ->
    result = null
    @cities.forEach (city) ->
      result = city if name is city.name
    result

  getAll: -> @cities

  add: (data) ->
    @cities.push data
    @save()

  has: (name) -> @get(name)?

  remove: (name) ->
    @cities = @cities.filter (city) ->
      city.name isnt name
    @save()

  touch: (name) -> @update name, 'lastUpdate', +(new Date)

  needForUpdate: (name) ->
    city = @get name
    not city.lastUpdate or +(new Date) - city.lastUpdate > 10 * 60 * 1000

  update: (name, key, value) ->
    @cities = @cities.map (city) ->
      if city.name is name
        city[key] = value
      city
]


App.service 'Weather', ['Rest', 'City', class
  constructor: (Rest, City) ->
    @Rest = Rest
    @City = City

  get: (name, callback=angular.noop) ->
    if @City.needForUpdate name
      @Rest.getWeather name, (res) =>
        @City.update name, 'weather', res
        @City.touch name
        callback res
    else
      callback @City.get(name).weather
]


App.service 'Rest', ['$resource', class

  restUrl = 'http://api.worldweatheronline.com/free/v1/'

  resourceOptions =
    get:
      method: 'JSONP'
      params: callback: 'JSON_CALLBACK'

  defaultQuery =
    num_of_results: 1
    key: 'xqxeawkvwdcbrqr7qxtdhxp2'
    format: 'json'
    num_of_days: 5

  constructor: ($resource) ->
    @rest = {}
    @rest.weather = $resource restUrl + 'weather.ashx', defaultQuery, resourceOptions
    @rest.city = $resource restUrl + 'search.ashx', defaultQuery, resourceOptions

  getCityByGeoLocation: (lat, lon, callback=angular.noop) ->
    @rest.city.get {q: "#{lat},#{lon}"}, callback

  getCity: (city, callback=angular.noop) ->
    @rest.city.get {q: city}, callback

  getWeather: (cityName, callback=angular.noop) ->
    @rest.weather.get {q: cityName}, callback
]


App.service 'Options', ['Storage', class

  constructor: (Storage) ->
    @options = Storage.get('options') or temp: 'C'
    @save = -> Storage.set 'options', @options

  get: -> @options

  set: (key, value) ->
    @options[key] = value
    @save()
]