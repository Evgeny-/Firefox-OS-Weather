App = angular.module 'Weather', ['ngResource']

LANG = navigator.language

if LANG.indexOf('-') != -1
  LANG = LANG.split('-')[0]

if LANG.indexOf('_') != -1
  LANG = LANG.split('_')[0]

LANG = if LANG then LANG else 'en'


