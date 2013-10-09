App.controller 'MainController', ['$rootScope', ($rootScope) ->
  $rootScope.openedOptions = yes

  $rootScope.toggleOptions = ->
    $rootScope.openedOptions = not $rootScope.openedOptions

  $rootScope.update = ->
    $rootScope.$emit 'update:city', yes
]


App.controller 'OptionsController',
  ['$scope', '$rootScope', 'Rest', '$timeout', 'City', 'Options', ($scope, $rootScope, Rest, $timeout, City, Options) ->
    errors = [
      'Please enter city name'
      'No cities found'
      'You already have this city'
      'Cant get geolocation']

    $scope.cities = City.getAll()
    $scope.cityName = null
    $scope.loading = no
    $scope.options = Options.get()

    $scope.showError = (error) ->
      $scope.error = error
      $timeout (-> $scope.error = null), 2000

    $scope.useGeoLocation = () ->
      navigator.geolocation.getCurrentPosition ((pos) ->
        Rest.getCityByGeoLocation pos.coords.latitude, pos.coords.longitude, (res) ->

          if res.search_api?.result?.areaName?.value
            name = res.search_api.result.areaName.value
            return $scope.showError errors[2] if City.has name
            City.add
              name: name
              searchQuery: name
              lastUpdate: null
              weather: null

          else
            $scope.showError errors[1]

          $scope.$apply()
      ), -> $scope.showError errors[3]

    $scope.saveOptions = -> Options.save()

    $scope.openCity = (city) ->
      $rootScope.$emit 'open:city', city if City.has(city)

    $scope.removeCity = (name) ->
      if confirm "Are you sure want to delete #{name}?"
        City.remove name
        $scope.cities = City.getAll()

    $scope.loadCity = ->
      return $scope.showError errors[0] unless $scope.cityName
      $scope.loading = yes

      Rest.getCity $scope.cityName, (result) ->
        $scope.loading = no
        return $scope.showError errors[1] unless result['search_api']
        $scope.cityName = null
        city = resultToCity result['search_api']['result'][0]
        return $scope.showError errors[2] if City.has city.name
        City.add city
        $scope.cities = City.getAll()

    resultToCity = (res) ->
      name: res['areaName'][0]['value']
      searchQuery: res['areaName'][0]['value']
      lastUpdate: null
      weather: null
  ]


App.controller 'WeatherController', ['$scope', '$rootScope', 'Weather', 'Options', 'City', ($scope, $rootScope, Weather, Options, City) ->
  options = Options.get()

  $scope.loading = no
  $scope.now = null
  $scope.days = null
  $scope.city = null

  $scope.showDay = (day) ->
    result = ""
    for key, value of day
      continue if key is '$$hashKey' or key is 'icon'
      result += "#{key}: #{value}\n"
    alert result

  $rootScope.$on 'open:city', (e, city) ->
    loadWeather city
    $scope.city = city
    $rootScope.toggleOptions()

  $rootScope.$on 'update:city', () ->
    if $scope.city
      City.update $scope.city, 'lastUpdate', null
      loadWeather $scope.city


  parseNow = (now) ->
    temp : [now['temp_C'], now['temp_F']][+(options.temp is 'F')]
    icon : ICONS[now['weatherCode']][0]
    desc : now['weatherDesc'][0]['value']

  parseDays = (days) ->
    days.map (day) ->
      day  : getDay(+(new Date day.date ).getDay()) or day['date']
      date : day['date']
      max  : [day['tempMaxC'], day['tempMaxF']][+(options.temp is 'F')]
      min  : [day['tempMinC'], day['tempMinF']][+(options.temp is 'F')]
      weather : day['weatherDesc'][0]['value']
      precip : day['precipMM'] + 'mm'
      windspeed : day['windspeedKmph'] + 'km/h'
      icon : ICONS[day['weatherCode']][0]

  getDay = (d) ->
    ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][d]

  loadWeather = (city) ->
    $scope.now = null
    $scope.days = null
    $scope.loading = yes
    Weather.get city, (res) ->
      $scope.now = parseNow res['data']['current_condition'][0]
      $scope.days = parseDays res['data']['weather']
      $scope.loading = no
]