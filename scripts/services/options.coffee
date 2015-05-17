App.service 'Options', ['Storage', class
  defaultOptions:
    temp: 'C'
    start: App.m.options.options_menu

  constructor: (Storage) ->
    @options = Storage.get('options') or @defaultOptions
    @save = -> Storage.set 'options', @options

  get: -> @options

  set: (key, value) ->
    @options[key] = value
    @save()
]