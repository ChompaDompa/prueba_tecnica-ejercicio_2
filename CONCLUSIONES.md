# Conclusiones y hallazgos – Ejercicio 2 (API Demoblaze: signup / login)

> Versión en Markdown de [`conclusiones.txt`](conclusiones.txt), el archivo exigido por el enunciado.

## 1. Resumen de ejecución

| | |
|---|---|
| **Herramienta** | Karate 1.5.1 + JUnit 5 + Maven (wrapper) |
| **Resultado** | 7 escenarios ejecutados: 7 exitosos, 0 fallidos |
| **Evidencia** | [`reports/karate-reports/karate-summary.html`](reports/karate-reports/karate-summary.html) y [`reports/karate.log`](reports/karate.log) |

## 2. Entradas y salidas identificadas

Ambos servicios reciben un `POST` con el header `Content-Type: application/json` y este body:

```json
{ "username": "<texto>", "password": "<password codificado en Base64>" }
```

Ejemplo: el password `Softka2026*` se envía como `U29mdGthMjAyNio=`.

| # | Caso | Status | Salida (body) |
|---|---|---|---|
| 1 | Signup: usuario nuevo | 200 | `""` (string vacío) |
| 2a | Signup: usuario existente, mismo password | 200 | `{"errorMessage":"This user already exist."}` |
| 2b | Signup: usuario existente, otro password | 200 | `{"errorMessage":"This user already exist."}` |
| 3 | Login: usuario y password correctos | 200 | `"Auth_token: <token>"` |
| 4a | Login: password incorrecto | 200 | `{"errorMessage":"Wrong password."}` |
| 4b | Login: usuario inexistente | 200 | `{"errorMessage":"User does not exist."}` |
| 4c | Login: usuario y password incorrectos | 200 | `{"errorMessage":"User does not exist."}` |

## 3. Hallazgos

### H1. Códigos HTTP no semánticos

Todos los casos, exitosos o de error, responden **HTTP 200**, así que el resultado solo se distingue leyendo el body. Lo esperado en una API REST sería:

| Caso | Esperado |
|---|---|
| Signup exitoso | `201 Created` |
| Usuario ya existente | `409 Conflict` |
| Credenciales inválidas | `401 Unauthorized` |

**Impacto:** los clientes y monitores que se basan en el status code no detectan los errores. Por eso las pruebas validan siempre el body.

### H2. Formato de respuesta inconsistente

Los errores devuelven un objeto JSON (`{"errorMessage": ...}`), pero los casos exitosos devuelven un string JSON (`""` en signup y `"Auth_token: ..."` en login). El token viene concatenado dentro de un texto y no en un campo propio (por ejemplo, `{"token": "..."}`), lo que obliga al cliente a parsearlo manualmente.

### H3. Token de autenticación predecible (riesgo de seguridad)

El token devuelto es simplemente `Base64(username + número)`. Ejemplo:

```
Auth_token: cWFfbG9naW5fMTc5NTEzOTM4OTY5M185OGYzM2Y4ZDE3OTU3Mzk=
decodificado → qa_login_1795139389693_98f33f8d1795739
```

No es un token firmado ni aleatorio (como un JWT), por lo que un atacante podría adivinarlo o falsificarlo.

### H4. Password "protegido" solo con Base64

Base64 es una **codificación, no un cifrado**: cualquiera que intercepte el request puede decodificar el password. La protección real depende únicamente de HTTPS.

### H5. Enumeración de usuarios

El login responde mensajes distintos para `Wrong password.` y `User does not exist.`, y el signup confirma `This user already exist.`. Esto permite a un atacante descubrir qué usuarios están registrados.

**Recomendación:** usar un mensaje genérico, por ejemplo *"Usuario o password inválidos"*.

### H6. Errores ortográficos en mensajes

`This user already exist.` debería ser `This user already exists.`

### H7. Inestabilidad intermitente del servicio / conexión

Durante las ejecuciones hubo fallos esporádicos no relacionados con la lógica de negocio: `Network is unreachable`, `Connect timed out` y `Remote host terminated the handshake` (SSL).

Se mitigaron forzando IPv4 y TLS 1.2 en la JVM (`-Djava.net.preferIPv4Stack=true -Djdk.tls.client.protocols=TLSv1.2`) y aumentando los timeouts a 30 s. Tras estos ajustes, las ejecuciones consecutivas fueron 100 % exitosas.

### H8. Sin validaciones aparentes ni limpieza de datos

El servicio permite registrar usuarios con nombres arbitrarios y no expone un endpoint para eliminarlos, así que cada ejecución deja usuarios en la base de datos de Demoblaze. Por eso las pruebas generan usernames únicos (prefijo + timestamp + UUID).

## 4. Decisiones de diseño de las pruebas

- **Datos dinámicos:** cada escenario crea sus propios usuarios, de modo que las pruebas son independientes, repetibles y no dependen de datos preexistentes.
- **Reutilización:** la creación de usuarios está en un feature helper (`common/create-user.feature`) invocado con `call` en scope aislado, y solo en los escenarios que realmente necesitan un usuario existente. Así se hacen menos llamadas a una API inestable (ver H7).
- **Duplicado con otro password:** el signup duplicado también se prueba con un password distinto, para confirmar que la unicidad se valida por username y no por la pareja username + password.
- **Validación del token:** el login exitoso decodifica el `Auth_token` y verifica que pertenezca al usuario autenticado, no solo que exista un token.
- **Sin falsos verdes:** el runner falla si no se ejecuta ningún escenario (por ejemplo, por un tag mal escrito).
- **Lecciones de la automatización:** las funciones definidas en `karate-config.js` no conservan variables externas (closures), y una expresión embebida `#(...)` que falla se envía como texto literal sin error. Por eso las transformaciones se hacen en un paso `def` explícito, que si falla detiene la prueba con un mensaje claro.
- **Scenario Outline** para cubrir varias combinaciones de datos con un solo escenario parametrizado.
- **Tags** (`@signup`, `@login`, `@smoke`, etc.) para ejecutar subconjuntos.
- **Trazabilidad:** cada escenario imprime ENTRADA y SALIDA en el reporte, tal como lo pide el ejercicio.

## 5. Conclusión

Los servicios de signup y login de Demoblaze **cumplen funcionalmente** los cuatro casos solicitados: registran usuarios nuevos, rechazan usuarios duplicados, autentican credenciales válidas y rechazan las inválidas.

Sin embargo, el diseño de la API tiene **debilidades importantes**: códigos HTTP no semánticos, formatos de respuesta inconsistentes y varias prácticas de seguridad débiles (token predecible, enumeración de usuarios, password solo en Base64). Se recomienda corregirlas antes de un uso productivo.

Karate permitió automatizar y documentar todos los casos de forma legible, repetible y con reportes listos para compartir.
