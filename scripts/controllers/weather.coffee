App.controller 'WeatherController',
  ['$scope', '$rootScope', 'Weather', 'Options', 'City',
    ($scope, $rootScope, Weather, Options, City) ->
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

      $rootScope.$on 'update:city', () ->
        if $scope.city
          city = City.get $scope.city
          if(+new Date - city.lastUpdate > 15 * 60 * 1000)
            City.update $scope.city, 'lastUpdate', null
            loadWeather $scope.city


      parseNow = (now) ->
        temp : [now['temp_C'], now['temp_F']][+(options.temp is 'F')]
        icon : ICONS[now['weatherCode']][0]
        desc : now['weatherDesc'][0]['value']
        windspeed: now['windspeedKmph']
        winddir: getWind(now['winddir16Point'])
        pressure: now['pressure']

      getWind = (path) ->
        return path
        if path.match /^[A-Z]{3}$/
          path.slice 1
        else if path.match /^[A-Z]b[A-Z]$/
          path[0] + path[2]
        else path


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
        App.m.days.list[d]

      loadWeather = (city) ->
        $scope.now = null
        $scope.days = null
        $scope.loading = yes
        Weather.get city, (res) ->
          $scope.now = parseNow res['data']['current_condition'][0]
          $scope.days = parseDays res['data']['weather']
          $scope.loading = no
  ]