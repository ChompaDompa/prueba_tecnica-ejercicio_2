===============================================================================
 PRUEBA TECNICA QA AUTOMATION - EJERCICIO 2
 Pruebas de servicios REST de Demoblaze (signup / login) con Karate
===============================================================================

1. DESCRIPCION
-------------------------------------------------------------------------------
Proyecto de automatizacion de pruebas de API sobre los servicios:

  - Signup: POST https://api.demoblaze.com/signup
  - Login : POST https://api.demoblaze.com/login

Casos cubiertos:
  1. Crear un nuevo usuario en signup                 (@signup-ok)
  2. Intentar crear un usuario ya existente           (@signup-existing)
       2.1 Mismo username y mismo password
       2.2 Mismo username con password diferente
  3. Usuario y password correcto en login             (@login-ok)
       Valida ademas que el Auth_token pertenezca al usuario autenticado.
  4. Usuario y password incorrecto en login           (@login-wrong-credentials)
       4.1 Usuario correcto, password incorrecto      (@login-wrong-password)
       4.2 Usuario inexistente                        (@login-user-not-found)
       4.3 Usuario y password incorrectos             (@login-user-not-found)

  Total: 7 escenarios.

Cada escenario imprime la ENTRADA (request) y la SALIDA (status + body) y
queda registrado en el reporte HTML de Karate.


2. TECNOLOGIAS
-------------------------------------------------------------------------------
  - Java 17 o superior (probado con Java 27)
  - Karate 1.5.1 (io.karatelabs:karate-junit5)
  - JUnit 5
  - Maven 3.9.9 mediante Maven Wrapper (mvnw / mvnw.cmd): NO es necesario
    instalar Maven, el wrapper lo descarga automaticamente.


3. PRERREQUISITOS
-------------------------------------------------------------------------------
  1. Tener instalado un JDK 17+ y la variable JAVA_HOME configurada
     (verificar con: java -version).
  2. Tener Git instalado (verificar con: git --version).
  3. Conexion a internet (los servicios de demoblaze son publicos).


4. ESTRUCTURA DEL PROYECTO
-------------------------------------------------------------------------------
  prueba_tecnica-ejercicio_2/
  |-- pom.xml                          Dependencias y configuracion de Maven
  |-- mvnw / mvnw.cmd / .mvn/          Maven Wrapper
  |-- readme.txt                       Este archivo
  |-- conclusiones.txt                 Hallazgos y conclusiones
  |-- reports/                         Evidencia de una ejecucion real
  |   |-- karate-reports/              Reporte HTML de Karate (abrir karate-summary.html)
  |   |-- karate.log                   Log completo con requests y responses
  |-- src/test/java/
      |-- karate-config.js             Configuracion global (baseUrl, utilidades)
      |-- logback-test.xml             Configuracion de logs
      |-- demoblaze/
          |-- DemoblazeRunner.java     Runner JUnit 5
          |-- signup/signup.feature    Escenarios de signup
          |-- login/login.feature      Escenarios de login
          |-- common/create-user.feature  Helper reutilizable para crear usuarios


5. PASOS DE EJECUCION
-------------------------------------------------------------------------------
  Paso 1. Clonar el repositorio:
          git clone https://github.com/ChompaDompa/prueba_tecnica-ejercicio_2.git
          cd prueba_tecnica-ejercicio_2

  Paso 2. Ejecutar todas las pruebas:
          Windows (PowerShell / CMD):  .\mvnw.cmd clean test
          Linux / macOS / Git Bash:    ./mvnw clean test

          La primera ejecucion descarga Maven y las dependencias (puede tardar
          un par de minutos).

  Paso 3. (Opcional) Ejecutar solo un grupo de escenarios por tag:
          .\mvnw.cmd clean test "-Dkarate.options=--tags @signup"
          .\mvnw.cmd clean test "-Dkarate.options=--tags @login"
          .\mvnw.cmd clean test "-Dkarate.options=--tags @smoke"

          Tags disponibles: @signup, @login, @smoke, @signup-ok,
          @signup-existing, @login-ok, @login-wrong-credentials,
          @login-wrong-password, @login-user-not-found

          Si el filtro no selecciona ningun escenario (por ejemplo un tag mal
          escrito), la ejecucion FALLA con el mensaje "No se ejecuto ningun
          escenario", para evitar un falso resultado exitoso.

  Paso 4. Revisar resultados:
          - En consola se muestra el resumen: "scenarios: 7 | passed: 7 | failed: 0"
          - Reporte HTML: target/karate-reports/karate-summary.html
            (abrirlo en el navegador; en cada escenario se ve el request,
             el response y los mensajes de ENTRADA / SALIDA)
          - Log completo: target/karate.log
          - Reporte Cucumber JSON: target/karate-reports/*.json


6. NOTAS
-------------------------------------------------------------------------------
  - Los usernames se generan dinamicamente (prefijo + timestamp + UUID), por lo
    que las pruebas se pueden ejecutar todas las veces que se quiera sin
    colisiones ni limpieza de datos.
  - El password se envia codificado en Base64, igual que lo hace la pagina web
    de demoblaze (funcion btoa de JavaScript, que usa el charset Latin-1).
  - El log target/karate.log se sobrescribe en cada ejecucion, de modo que la
    evidencia corresponde siempre a una sola corrida. Contiene requests y
    responses completos; los passwords usados son datos de prueba ficticios.
  - El pom.xml configura -Djava.net.preferIPv4Stack=true y
    -Djdk.tls.client.protocols=TLSv1.2 para evitar fallos intermitentes de
    conexion/handshake SSL observados contra api.demoblaze.com con JDKs
    recientes (ver conclusiones.txt).
