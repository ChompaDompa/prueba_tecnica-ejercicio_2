# Prueba técnica QA Automation – Ejercicio 2

Pruebas automatizadas de los servicios REST de **Demoblaze** (signup / login) con **Karate**.

> Este README es la versión en Markdown de [`readme.txt`](readme.txt), el archivo exigido por el enunciado. Los hallazgos están en [`CONCLUSIONES.md`](CONCLUSIONES.md) ([`conclusiones.txt`](conclusiones.txt)).

## 1. Descripción

Servicios bajo prueba:

| Servicio | Método | URL |
|---|---|---|
| Signup | `POST` | `https://api.demoblaze.com/signup` |
| Login | `POST` | `https://api.demoblaze.com/login` |

### Casos cubiertos (7 escenarios)

| # | Caso | Tag |
|---|---|---|
| 1 | Crear un nuevo usuario en signup | `@signup-ok` |
| 2.1 | Usuario ya existente, mismo username y mismo password | `@signup-existing` |
| 2.2 | Usuario ya existente, mismo username con password diferente | `@signup-existing` |
| 3 | Usuario y password correctos en login (valida además que el `Auth_token` pertenezca al usuario) | `@login-ok` |
| 4.1 | Usuario correcto, password incorrecto | `@login-wrong-password` |
| 4.2 | Usuario inexistente | `@login-user-not-found` |
| 4.3 | Usuario y password incorrectos | `@login-user-not-found` |

Cada escenario imprime la **ENTRADA** (request) y la **SALIDA** (status + body), y todo queda registrado en el reporte HTML de Karate.

## 2. Tecnologías

- Java 17 o superior (probado con Java 27)
- Karate 1.5.1 (`io.karatelabs:karate-junit5`)
- JUnit 5
- Maven 3.9.9 mediante **Maven Wrapper** (`mvnw` / `mvnw.cmd`): no hace falta instalar Maven, porque el wrapper lo descarga automáticamente.

## 3. Prerrequisitos

1. JDK 17+ instalado y `JAVA_HOME` configurado (verificar con `java -version`).
2. Git instalado (verificar con `git --version`).
3. Conexión a internet (los servicios de Demoblaze son públicos).

## 4. Estructura del proyecto

```
prueba_tecnica-ejercicio_2/
├── pom.xml                           Dependencias y configuración de Maven
├── mvnw / mvnw.cmd / .mvn/           Maven Wrapper
├── README.md / readme.txt            Instrucciones de ejecución
├── CONCLUSIONES.md / conclusiones.txt  Hallazgos y conclusiones
├── reports/                          Evidencia de una ejecución real
│   ├── karate-reports/               Reporte HTML de Karate (abrir karate-summary.html)
│   └── karate.log                    Log completo con requests y responses
└── src/test/java/
    ├── karate-config.js              Configuración global (baseUrl, utilidades)
    ├── logback-test.xml              Configuración de logs
    └── demoblaze/
        ├── DemoblazeRunner.java      Runner JUnit 5
        ├── signup/signup.feature     Escenarios de signup
        ├── login/login.feature       Escenarios de login
        └── common/create-user.feature  Helper reutilizable para crear usuarios
```

## 5. Pasos de ejecución

**Paso 1. Clonar el repositorio**

```bash
git clone https://github.com/ChompaDompa/prueba_tecnica-ejercicio_2.git
cd prueba_tecnica-ejercicio_2
```

**Paso 2. Ejecutar todas las pruebas**

```powershell
# Windows (PowerShell / CMD)
.\mvnw.cmd clean test
```

```bash
# Linux / macOS / Git Bash
./mvnw clean test
```

La primera ejecución descarga Maven y las dependencias, así que puede tardar un par de minutos.

**Paso 3 (opcional). Ejecutar solo un grupo de escenarios por tag**

```powershell
.\mvnw.cmd clean test "-Dkarate.options=--tags @signup"
.\mvnw.cmd clean test "-Dkarate.options=--tags @login"
.\mvnw.cmd clean test "-Dkarate.options=--tags @smoke"
```

Tags disponibles: `@signup`, `@login`, `@smoke`, `@signup-ok`, `@signup-existing`, `@login-ok`, `@login-wrong-credentials`, `@login-wrong-password`, `@login-user-not-found`.

> Si el filtro no selecciona ningún escenario (por ejemplo, un tag mal escrito), la ejecución **falla** con el mensaje *"No se ejecuto ningun escenario"*, para evitar un falso resultado exitoso.

**Paso 4. Revisar resultados**

- En consola aparece el resumen: `scenarios: 7 | passed: 7 | failed: 0`.
- Reporte HTML: `target/karate-reports/karate-summary.html`. Al abrirlo en el navegador, cada escenario muestra el request, el response y los mensajes de ENTRADA / SALIDA.
- Log completo: `target/karate.log`.
- Reporte Cucumber JSON: `target/karate-reports/*.json`.

## 6. Notas

- Los usernames se generan dinámicamente (prefijo + timestamp + UUID), por lo que las pruebas se pueden ejecutar todas las veces que se quiera sin colisiones ni limpieza de datos.
- El password se envía codificado en Base64, igual que lo hace la página web de Demoblaze (función `btoa` de JavaScript, que usa el charset Latin-1).
- `target/karate.log` se sobrescribe en cada ejecución, así que la evidencia corresponde siempre a una sola corrida. Contiene requests y responses completos; los passwords usados son datos de prueba ficticios.
- El `pom.xml` configura `-Djava.net.preferIPv4Stack=true` y `-Djdk.tls.client.protocols=TLSv1.2` para evitar fallos intermitentes de conexión y de handshake SSL observados contra `api.demoblaze.com` con JDKs recientes (ver [CONCLUSIONES.md](CONCLUSIONES.md#h7-inestabilidad-intermitente-del-servicio--conexión)).
