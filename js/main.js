
var ICONS = {
   "395" : ["weezle_sun_and_snow", "weezle_night_and_snow"],
   "392" : ["weezle_sun_thunder_rain", "weezle_night_thunder_rain"],
   "389" : ["weezle_cloud_thunder_rain", "weezle_cloud_thunder_rain"],
   "386" : ["weezle_sun_thunder_rain", "weezle_night_thunder_rain"],
   "377" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "374" : ["weezle_sun_medium_ice", "weezle_night_and_snow"],
   "371" : ["weezle_sun_medium_ice", "weezle_night_and_snow"],
   "368" : ["weezle_sun_flurrie", "weezle_night_flurry"],
   "365" : ["weezle_sun_medium_ice", "weezle_night_and_snow"],
   "362" : ["weezle_sun_medium_ice", "weezle_night_and_snow"],
   "359" : ["weezle_rain", "weezle_rain"],
   "356" : ["weezle_sun_medium_rain", "weezle_night_rain"],
   "353" : ["weezle_sun_and_rain", "weezle_night_rain"],
   "350" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "338" : ["weezle_snow", "weezle_snow"],
   "335" : ["weezle_sun_and_snow", "weezle_night_and_snow"],
   "332" : ["weezle_snow", "weezle_snow"],
   "329" : ["weezle_snow", "weezle_snow"],
   "326" : ["weezle_sun_flurrie", "weezle_night_flurry"],
   "323" : ["weezle_sun_flurrie", "weezle_night_flurry"],
   "320" : ["weezle_snow", "weezle_snow"],
   "317" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "314" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "311" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "308" : ["weezle_rain", "weezle_rain"],
   "305" : ["weezle_sun_medium_rain", "weezle_night_rain"],
   "302" : ["weezle_rain", "weezle_rain"],
   "299" : ["weezle_sun_medium_rain", "weezle_night_rain"],
   "296" : ["weezle_rain", "weezle_rain"],
   "293" : ["weezle_rain", "weezle_rain"],
   "284" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "281" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "266" : ["weezle_rain", "weezle_rain"],
   "263" : ["weezle_sun_medium_rain", "weezle_night_rain"],
   "260" : ["weezle_fog", "weezle_night_fog"],
   "248" : ["weezle_fog", "weezle_night_fog"],
   "230" : ["weezle_snow", "weezle_snow"],
   "227" : ["weezle_snow", "weezle_snow"],
   "200" : ["weezle_sun_thunder_rain", "weezle_night_thunder_rain"],
   "185" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "182" : ["weezle_rain_and_snow", "weezle_rain_and_snow"],
   "179" : ["weezle_sun_medium_ice", "weezle_night_and_snow"],
   "176" : ["weezle_sun_medium_rain", "weezle_night_rain"],
   "143" : ["weezle_fog", "weezle_night_fog"],
   "122" : ["weezle_max_cloud", "weezle_max_cloud"],
   "119" : ["weezle_cloud", "weezle_cloud"],
   "116" : ["weezle_sun_minimal_clouds", "weezle_moon_cloud"],
   "113" : ["weezle_sun", "weezle_fullmoon"],
}

var ajax = (function(){
   var _serialize = function(obj) {
      var str = [];
      for(var p in obj) {
         if(p === '_cb') continue;
         str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
      }
      return str.join("&");
   }

   return {
      jsonp : function(url, data, callback) {
         if(typeof data === 'function') {
            callback = data;
         }
         else if(typeof data === 'object') {
            url += (url.indexOf('?') === -1 ? '?' : '&') + _serialize(data);
         }

         var func   = 'CB' + (Math.random() * 10000 | 0),
            script = document.createElement('script');
         
         window[func] = function() {
            callback.apply(arguments[0], arguments);
            script.parentNode.removeChild(script);
            delete window[func];
         }

         script.src = url + (url.indexOf('?') === -1 ? '?' : '&') + (data['_cb'] || 'callback') + '=' + func;
         document.querySelector('head').appendChild(script);
      },

      get : function(url, data, callback) {
         if(typeof data === 'function') {
            callback = data;
         }
         else if(typeof data === 'object') {
            url += (url.indexOf('?') === -1 ? '?' : '&') + _serialize(data);
         }
         var xhr = new XMLHttpRequest();

         xhr.open('GET', url, true);
         xhr.onreadystatechange = function() {
            if(xhr.readyState == 4) {
               callback(xhr.responseText);
            }
         }
         xhr.send(null);
      },

      post : function(url, data, callback) {
         if(typeof data === 'function') {
            callback = data;
            data = false;
         }
         var xhr = new XMLHttpRequest();

         xhr.open('POST', url, true);
         xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
         xhr.onreadystatechange = function() {
            if(xhr.readyState == 4) {
               callback(xhr.responseText);
            }
         }
         xhr.send(_serialize(data || {}));
      }
   }
}());


var Store = (function(){

   return {
      save : function(key, data) {
         if(typeof key === 'object') {
            for(var k in key) {
               var res = typeof key[k] === 'object' ? JSON.stringify(key[k]) : key[k];
               localStorage.setItem(k, res);
            }
         }
         else {
            var res = typeof data === 'object' ? JSON.stringify(data) : data;
            localStorage.setItem(key, res);
         }
      },

      get : function(key, json) {
         var res = localStorage.getItem(key);
         return res && json ? JSON.parse(res) : res;
      }
   }

}());


var Config = (function(){
   function Config() {
      var config = Store.get('settings', true) || {};
      this.q           = config.q           || 'london';
      this.key         = config.key         || 'fc5cc026a1105351130703';
      this.num_of_days = config.num_of_days ||  5;
      this.format      = config.format      || 'json';
      this.temp        = config.temp        || 'C';
   }

   Config.prototype.save = function(){
      Store.save('settings', this);
   }

   Config.prototype.isset = function(){
      return !!Store.get('settings');
   }

   return Config;
}());



var Weather = (function(){
   function Weather() {

   }

   var _error = function(msg) {
      Action.fail(msg)
   }

   var _handle = function(res) {
      if('error' in res.data) {
         return _error(res.data.error[0]['msg']);
      }
      _show(res);
      _cache.insert(res);
   }

   var _handleCheck = function(callback) {
      return function(res) {
         var check =  ! ('error' in res.data);
         if(check) _cache.insert(res);
         callback(check, check ? null : res.data.error[0]['msg']);
      }
   }

   var _cache = {
      insert : function(data){
         Store.save('cache', {
            time : Math.round(+new Date()/1000),
            data : data
         });

      },
      isset : function(){
         var data = Store.get('cache', true);
         if(data === null) return false;
         return Math.round(+new Date()/1000) - data.time < 30*60;
      },
      load : function(){
         return Store.get('cache', true)['data'];
      }
   }

   var _parse = function(res) {
      var a = res.data.current_condition[0],
         config = new Config,
         _night = (new Date).getHours();   _night = _night > 19 || _night < 7;
      var _getDay = function(d) {
         return ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][d];
      }
      var _city = function(city) {
         if(!city.match(/^Lat ([0-9\.]+) and Lon ([0-9\.]+)$/i)) return city;
         return city.replace(/^Lat ([0-9\.]+) and Lon ([0-9\.]+)$/i, '$1, $2');
      }

      var newres = {
         now : {
            city : _city(res.data.request[0].query),
            temp : [a.temp_C, a.temp_F][+(config.temp == 'F')],
            icon : ICONS[a.weatherCode][+_night],
            desc : a.weatherDesc[0].value
         },
         days : []
      };
      for(var i=0, l=res.data.weather.length; i<l; i++) {
         var day = res.data.weather[i];
         newres.days.push({
            day  : _getDay(+(new Date(day.date)).getDay()) || day.date,
            date : day.date,
            max  : [day.tempMaxC, day.tempMaxF][+(config.temp == 'F')],
            min  : [day.tempMinC, day.tempMinF][+(config.temp == 'F')],
            weather : day.weatherDesc[0].value,
            precip : day.precipMM + 'mm',
            windspeed : day.windspeedKmph + 'km/h',
            icon : ICONS[day.weatherCode][0],
         });
      }
      return newres;
   }

   var _show = function(res) {

      Template.get('weather', _parse(res)).insertTo('#weather');

      console.log(new Date - window['TIME_START']);
   }

   Weather.prototype.load = function(cache) {
      var config = new Config();
      if(_cache.isset() && ! cache) {
         return _show(_cache.load())
      }
      ajax.jsonp('http://free.worldweatheronline.com/feed/weather.ashx', {
            q          : config.q,
            key       : config.key,
            num_of_days : config.num_of_days,
            format       : config.format
         }, 
         _handle
      );
   }
   Weather.prototype.check = function(data, callback) {
      var config = new Config();
      ajax.jsonp('http://free.worldweatheronline.com/feed/weather.ashx', {
            q           : data.q,
            key         : data.key          || config.key,
            num_of_days : data.num_of_days  || config.num_of_days,
            format      : data.format       || config.format
         }, 
         _handleCheck(callback)
      );
   }
   return Weather;
}());


var Template = (function(){
   function Template(tpl) {
      this.tpl = tpl;
   }

   Template.prototype.insertTo = function(el) {
      _ge(el).innerHTML = this.tpl;
      return this;
   }
   Template.prototype.appendTo = function(el) {
      _ge(el).innerHTML += this.tpl;
      return this;
   }
   Template.prototype.prependTo = function() {
      el = _ge(el);
      el.innerHTML = this.tpl + el.innerHTML;
      return this;
   }

   var _ge = function(el) {
      return typeof el === 'string' ? document.querySelector(el) : el;
   }

   var _getTemplate = function(id) {
      return doT.template( document.getElementById(id).innerHTML );
   }

   var _listTemplates = {};

   return {
      prepare : function(tpls) {
         if(typeof tpls === 'object') {
            for(var i=0, l=tpls.length; i<l; i++) {
               _listTemplates[tpls[i]] = _getTemplate('tpl_' + tpls[i]);
            }
         } 
         else {
            _listTemplates[tpls] = _getTemplate('tpl_' + tpls);
         }
         return this;
      },

      get : function(tpl, data) {
         if( ! (tpl in _listTemplates)) {
            this.prepare(tpl);
         }
         return new Template(_listTemplates[tpl](data));
      }
   }
}());


var Action = (function(){
   return {
      fail : function(text) {
         console.log(text)
         alert(text)
      },
      choose : function(dspl) {
         document.getElementById('choose').style.display = dspl || 'show';
      },

      chooseToggle : function() {
         var e = document.getElementById('choose');
         e.style.display = e.style.display === 'none' ? 'block' : 'none';
      },

      showDay : function(res) {
         var string = "";
         for(var k in res) {
            if(k === 'icon') continue;
            string += k + ': ' + res[k] + '\n';
         }
         alert(string);
      }
   }
}());


;(function(){
   window['TIME_START'] = new Date;
   Template.prepare(['weather']);

   var weather = new Weather,
      config  = new Config;

   if(config.isset()) {
      weather.load();
      setInterval(weather.load, 1000 * 60 * 30)
   }
   else {
      Action.choose('block');
   }

   document.getElementById('b-geolocation').addEventListener('click', function(){
      window['TIME_START'] = new Date;
      //Action.wait()
      navigator.geolocation.getCurrentPosition(
         function (position) {
            var coords = position.coords.latitude + ',' + position.coords.longitude;
            weather.check({q:coords}, function(res, error) {
               if(res === true) {
                  config.q = coords;
                  config.save();
                  weather.load();
                  Action.choose('none')
               } 
               else {
                  Action.fail(error);
               }
            });
         },
         function (error) {
            Action.fail('Cant get geolocation');
         }
      );
   });

   document.getElementById('b-cityname').addEventListener('click', function(){
      window['TIME_START'] = new Date;

      var city = document.getElementById('city').value;
      weather.check({q:city}, function(res, error) {
         if(res === true) {
            config.q = city;
            config.save();
            weather.load();
            Action.choose('none');
         } 
         else {
            Action.fail(error);
         }
      });
   });

   document
      .getElementById('temptype')
      .addEventListener('change', function(e) {
         config.temp = e.target.value;
         config.save();
         weather.load();
   });

   document
      .getElementById('reload')
      .addEventListener('click', function() {
         window['TIME_START'] = new Date;
         weather.load(false);
   });

   document
      .getElementById('settings')
      .addEventListener('click', Action.chooseToggle);

   document
      .querySelector('#temptype [value="'+config.temp+'"]')
      .setAttribute('selected', 'selected');
}());