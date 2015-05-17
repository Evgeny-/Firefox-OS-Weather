App.m = do ->
  parse = (obj, result) ->
    result = result or {}

    for key, value of obj
      if typeof value is 'string' or value instanceof Array
        return if obj[LANG] then obj[LANG] else obj.en
      else
        result[key] = parse value

    result

  parse DICT

App.run ['$rootScope', ($rootScope) ->
  $rootScope.m = App.m
]

