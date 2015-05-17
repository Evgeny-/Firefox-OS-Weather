App.controller 'MainController',
  ['$rootScope', '$timeout', 'Options', 'City',
    ($rootScope, $timeout, Options, City) ->
      $rootScope.openedOptions = yes

      $rootScope.toggleOptions = ->
        $rootScope.openedOptions = not $rootScope.openedOptions

      $rootScope.update = ->
        $rootScope.$emit 'update:city', yes

      options = Options.get()
      cities = City.getAll().map (a) -> a.name

      if options.start isnt Options.defaultOptions.start
        return if cities.indexOf(options.start) is -1
        $rootScope.openedOptions = no
        $rootScope.hideChooseText = yes
        $timeout (->$rootScope.$emit 'open:city', options.start)
  ]