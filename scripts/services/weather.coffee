App.service 'Weather', ['Rest', 'City', class
  constructor: (Rest, City) ->
    @Rest = Rest
    @City = City

  get: (name, callback=angular.noop) ->
    city = @City.get(name).searchQuery or name
    if @City.needForUpdate name
      @Rest.getWeather city, (res) =>
        @City.update name, 'weather', res
        @City.touch name
        callback res
    else
      callback @City.get(name).weather
]