App.service 'Storage', [class
  get: (key, json = true) ->
    value = localStorage.getItem key
    unless json then value else JSON.parse value

  set: (key, value) ->
    value = JSON.stringify value if typeof value is 'object'
    localStorage.setItem key, value

  remove: (key) -> @set key, null
]
