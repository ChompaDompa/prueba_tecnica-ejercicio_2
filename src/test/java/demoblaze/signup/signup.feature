@signup
Feature: Servicio de registro (signup) de demoblaze
  Endpoint: POST https://api.demoblaze.com/signup
  Entrada : JSON { "username": <texto>, "password": <password codificado en Base64> }
  Salida  : HTTP 200 con body "" (exito) o { "errorMessage": <mensaje> } (error)

  Background:
    * url baseUrl
    * def createUser = read('classpath:demoblaze/common/create-user.feature')

  @smoke @signup-ok
  Scenario: Crear un nuevo usuario en signup
    * def username = uniqueUsername('qa_signup')
    * def body = { username: '#(username)', password: '#(toBase64(defaultPassword))' }
    * print 'ENTRADA signup (usuario nuevo):', body
    Given path 'signup'
    And request body
    When method post
    Then status 200
    * print 'SALIDA signup (usuario nuevo): status =', responseStatus, '| body =', response
    * print 'Content-Type de la respuesta:', karate.response.header('content-type')
    And match response == '#string'
    And match response.trim() == '""'

  @signup-existing
  Scenario Outline: Intentar crear un usuario ya existente - <caso>
    # Precondicion: el usuario ya existe (se crea con el helper, en scope aislado)
    * def username = uniqueUsername('qa_dup')
    * def created = call createUser { username: '#(username)', password: '#(defaultPassword)' }
    * def retryPassword = <password>
    * def body = { username: '#(username)', password: '#(toBase64(retryPassword))' }
    * print 'ENTRADA signup (usuario existente, <caso>):', body
    Given path 'signup'
    And request body
    When method post
    Then status 200
    * print 'SALIDA signup (usuario existente, <caso>): status =', responseStatus, '| body =', response
    And match response == { errorMessage: 'This user already exist.' }

    Examples:
      | caso               | password        |
      | mismo password     | defaultPassword |
      | password diferente | 'OtraClave456'  |
