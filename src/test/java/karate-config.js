function fn() {
  var env = karate.env || 'qa';
  karate.log('karate.env =', env);

  var config = {
    env: env,
    baseUrl: 'https://api.demoblaze.com',
    defaultPassword: 'Softka2026*'
  };

  // Codifica el password en Base64 igual que el front de demoblaze (btoa).
  // btoa trabaja sobre Latin-1 (ISO-8859-1), por eso se usa ese charset y no UTF-8.
  config.toBase64 = function (text) {
    var Base64 = Java.type('java.util.Base64');
    var bytes = new java.lang.String(text).getBytes('ISO-8859-1');
    return Base64.getEncoder().encodeToString(bytes);
  };

  // Decodifica un texto Base64 (se usa para validar el contenido del Auth_token)
  config.fromBase64 = function (text) {
    var Base64 = Java.type('java.util.Base64');
    var bytes = Base64.getDecoder().decode(text);
    return new java.lang.String(bytes, 'ISO-8859-1') + '';
  };

  // Genera un username unico para que las pruebas se puedan re-ejecutar sin colisiones
  config.uniqueUsername = function (prefix) {
    var uuid = java.util.UUID.randomUUID().toString().substring(0, 8);
    return (prefix || 'qa_user') + '_' + java.lang.System.currentTimeMillis() + '_' + uuid;
  };

  karate.configure('connectTimeout', 30000);
  karate.configure('readTimeout', 30000);
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  return config;
}
