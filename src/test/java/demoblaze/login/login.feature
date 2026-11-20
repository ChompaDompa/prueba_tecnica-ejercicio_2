@login
Feature: Servicio de autenticacion (login) de demoblaze
  Endpoint: POST https://api.demoblaze.com/login
  Entrada : JSON { "username": <texto>, "password": <password codificado en Base64> }
  Salida  : HTTP 200 con body "Auth_token: <token>" (exito) o { "errorMessage": <mensaje> } (error)

  Background:
    * url baseUrl
    * def createUser = read('classpath:demoblaze/common/create-user.feature')

  @smoke @login-ok
  Scenario: Usuario y password correcto en login
    # Precondicion: usuario registrado (scope aislado)
    * def username = uniqueUsername('qa_login')
    * def created = call createUser { username: '#(username)', password: '#(defaultPassword)' }
    * def body = { username: '#(username)', password: '#(toBase64(defaultPassword))' }
    * print 'ENTRADA login (credenciales correctas):', body
    Given path 'login'
    And request body
    When method post
    Then status 200
    * print 'SALIDA login (credenciales correctas): status =', responseStatus, '| body =', response
    And match response == '#string'
    And match response.trim() == '#regex "Auth_token: [A-Za-z0-9+/=]+"'
    * def authToken = response.trim().replace(/"/g, '').replace('Auth_token: ', '')
    * def decodedToken = fromBase64(authToken)
    * print 'Token obtenido:', authToken, '| decodificado:', decodedToken
    # El token debe pertenecer al usuario que inicio sesion: Base64(username + digitos)
    * assert decodedToken.startsWith(username)
    And match decodedToken.substring(username.length) == '#regex \\d+'

  @login-wrong-credentials @login-wrong-password
  Scenario: Usuario y password incorrecto en login - usuario correcto, password incorrecto
    # Precondicion: usuario registrado (scope aislado)
    * def username = uniqueUsername('qa_login')
    * def created = call createUser { username: '#(username)', password: '#(defaultPassword)' }
    * def wrongPassword = 'ClaveErrada123'
    * def body = { username: '#(username)', password: '#(toBase64(wrongPassword))' }
    * print 'ENTRADA login (usuario correcto, password incorrecto):', body
    Given path 'login'
    And request body
    When method post
    Then status 200
    * print 'SALIDA login (usuario correcto, password incorrecto): status =', responseStatus, '| body =', response
    And match response == { errorMessage: 'Wrong password.' }

  @login-wrong-credentials @login-user-not-found
  Scenario Outline: Usuario y password incorrecto en login - <caso>
    # No requiere precondicion: el usuario no existe
    * def loginUser = uniqueUsername('qa_noexiste')
    * def loginPassword = <password>
    * def body = { username: '#(loginUser)', password: '#(toBase64(loginPassword))' }
    * print 'ENTRADA login (<caso>):', body
    Given path 'login'
    And request body
    When method post
    Then status 200
    * print 'SALIDA login (<caso>): status =', responseStatus, '| body =', response
    And match response == { errorMessage: 'User does not exist.' }

    Examples:
      | caso                           | password         |
      | usuario inexistente            | defaultPassword  |
      | usuario y password incorrectos | 'ClaveErrada123' |
