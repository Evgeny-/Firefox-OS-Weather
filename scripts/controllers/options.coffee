App.controller 'OptionsController',
  ['$scope', '$rootScope', 'Rest', '$timeout', 'City', 'Options',
    ($scope, $rootScope, Rest, $timeout, City, Options) ->
      setStartOptions = ->
        options = [Options.defaultOptions.start]
        options = options.concat(City.getAll().map (a) -> a.name)

        $scope.startOptions = options

        if $scope.startOptions.indexOf($scope.options.start) is -1
          $scope.options.start = Options.defaultOptions.start
          Options.save()

      errors = [
        App.m.errors.name_empty
        App.m.errors.not_found
        App.m.errors.already_exists
        App.m.errors.geolocation_error]

      $scope.cities = City.getAll()
      $scope.cityName = null
      $scope.loading = no
      $scope.options = Options.get()

      setStartOptions()

      $scope.showError = (error) ->
        $scope.error = error
        $timeout (-> $scope.error = null), 2000

      $scope.useGeoLocation = () ->
        navigator.geolocation.getCurrentPosition ((pos) ->
          Rest.getCityByGeoLocation pos.coords.latitude, pos.coords.longitude, (res) ->

            if res.search_api?.result?[0].areaName?[0].value
              name = res.search_api.result[0].areaName[0].value
              return $scope.showError errors[2] if City.has name
              City.add
                name: name
                searchQuery: name
                lastUpdate: null
                weather: null
              setStartOptions()
            else
              $scope.showError errors[1]

            $scope.$apply()
        ), -> $scope.showError errors[3]

      $scope.saveOptions = -> Options.save()

      $scope.openCity = (city) ->
        $rootScope.$emit 'open:city', city if City.has(city)
        $rootScope.openedOptions = false

      $scope.removeCity = (name) ->
        if confirm App.alerts.confirm_delete
          City.remove name
          $scope.cities = City.getAll()
          setStartOptions()

      $scope.loadCity = ->
        return $scope.showError errors[0] unless $scope.cityName
        $scope.loading = yes

        Rest.getCity $scope.cityName, (result) ->
          $scope.loading = no
          return $scope.showError errors[1] unless result['search_api']
          $scope.cityName = null
          if result['search_api']['result'].length is 1
            city = resultToCity result['search_api']['result'][0]
            return $scope.showError errors[2] if City.has city.name
            City.add city
            $scope.cities = City.getAll()
            setStartOptions()
          else
            $scope.chooseCity = true;
            $scope.chooseCities = result['search_api']['result'];

      $scope.chooseCityFunc = (city) ->
        $scope.chooseCity = false
        city = resultToCityCoords city
        return $scope.showError errors[2] if City.has city.name
        City.add city
        $scope.cities = City.getAll()
        setStartOptions()

      resultToCity = (res) ->
        name: res['areaName'][0]['value']
        searchQuery: res['areaName'][0]['value']
        lastUpdate: null
        weather: null

      resultToCityCoords = (res) ->
        name: res['areaName'][0]['value']
        searchQuery: res['latitude'] + ',' + res['longitude']
        lastUpdate: null
        weather: null
  ]