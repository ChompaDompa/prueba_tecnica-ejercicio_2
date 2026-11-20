@ignore
Feature: Helper reutilizable - crear un usuario en demoblaze

  # Uso (con scope aislado):
  # * def created = call read('classpath:demoblaze/common/create-user.feature') { username: '...', password: '...' }
  Scenario: Crear usuario
    Given url baseUrl
    And path 'signup'
    * def encodedPassword = toBase64(password)
    And request { username: '#(username)', password: '#(encodedPassword)' }
    When method post
    Then status 200
    * print 'Precondicion - signup de', username, '-> body =', response
    # Si la API responde un error ({ errorMessage }) falla aqui mostrando el body real
    And match response == '#string'
    And match response.trim() == '""'
