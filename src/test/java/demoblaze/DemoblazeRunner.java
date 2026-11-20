package demoblaze;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Runner principal: ejecuta todos los .feature del paquete demoblaze
 * (excepto los marcados con @ignore, que son helpers reutilizables).
 * Se pueden filtrar escenarios con: -Dkarate.options="--tags @login"
 */
class DemoblazeRunner {

    @Test
    void runAll() {
        Results results = Runner.path("classpath:demoblaze")
                .tags("~@ignore")
                .outputCucumberJson(true)
                .parallel(1);
        // Evita un falso verde si un filtro de tags mal escrito no selecciona ningun escenario
        assertTrue(results.getScenariosTotal() > 0,
                "No se ejecuto ningun escenario: revise el filtro de tags o la ruta de los features");
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
