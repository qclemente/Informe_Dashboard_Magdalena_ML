# 5. Despliegue en Render

El dashboard se encuentra publicado como servicio web en Render, plataforma que construye y
ejecuta la aplicación a partir de un repositorio de GitHub. Este capítulo describe los
requisitos que la aplicación debe cumplir para funcionar en producción, el archivo de
configuración del servicio y el procedimiento seguido para el despliegue.

## 5.1 Requisitos de la aplicación

El servidor de desarrollo que inicia `app.run` está diseñado para el trabajo local y no para
atender solicitudes en producción, por lo que el servicio emplea Gunicorn, un servidor WSGI
que ejecuta la aplicación de Flask subyacente. Gunicorn requiere un objeto WSGI accesible
desde el módulo, función que cumple la variable `server = app.server` definida en `app.py`. La
llamada a `app.run` permanece dentro del bloque `if __name__ == "__main__"`, de modo que solo
se ejecuta en el uso local.

Las dependencias se fijan con versiones exactas en `requirements.txt`, lo que garantiza que
Render instale el mismo conjunto de paquetes con el que se desarrolló y verificó la
aplicación.

```text
dash==4.4.1
dash-bootstrap-components==2.0.4
plotly==7.1.0
pandas==2.3.3
gunicorn==23.0.0
```

Las versiones recientes de estas bibliotecas introducen cambios que afectan el código. En
Dash 4 el método `run_server` fue reemplazado por `run`, y en Plotly 7 la función
`scatter_mapbox` fue sustituida por `scatter_map`, que emplea MapLibre y no requiere una
clave de acceso para mostrar la capa de OpenStreetMap.

## 5.2 Archivo de configuración

Render admite la descripción del servicio mediante un archivo `render.yaml`, denominado
Blueprint, que se ubica en la raíz del repositorio y declara el tipo de servicio, el entorno
de ejecución, el plan, los comandos de construcción y arranque y las variables de entorno.

```yaml
services:
  - type: web
    name: dashboard-magdalena
    runtime: python
    plan: free
    buildCommand: pip install -r requirements.txt
    startCommand: gunicorn --chdir src app:server
    envVars:
      - key: PYTHON_VERSION
        value: "3.9.23"
```

El comando de construcción instala las dependencias. El comando de arranque indica a Gunicorn
que se sitúe en la carpeta `src` mediante la opción `--chdir` y que cargue el objeto `server`
del módulo `app`, sintaxis que se lee como módulo seguido del nombre del objeto. La variable
`PYTHON_VERSION` fija la versión de Python del entorno de desarrollo, dado que la versión
predeterminada de Render es más reciente y podría resolver las dependencias de forma
distinta.

## 5.3 Procedimiento

El despliegue se realizó en cuatro pasos. En primer lugar, se creó un repositorio público en
GitHub, `Dashboard_Magdalena_ML`, y se subieron los archivos de la aplicación, los datos
precalculados, `requirements.txt` y `render.yaml`. En segundo lugar, desde el panel de
Render se eligió la opción de crear un nuevo Blueprint y se indicó la dirección pública del
repositorio. En tercer lugar, Render leyó el archivo `render.yaml`, mostró el servicio que se
crearía y, tras la confirmación, ejecutó el comando de construcción e inició la aplicación con
el comando de arranque. En cuarto lugar, se verificó que la dirección asignada,
[https://dashboard-magdalena.onrender.com](https://dashboard-magdalena.onrender.com),
respondiera correctamente y que las tres pestañas mostraran sus secciones.

El repositorio se vinculó mediante su dirección pública, sin conceder a Render acceso a la
cuenta de GitHub. En esa modalidad el despliegue automático no se activa, de modo que cada
modificación subida al repositorio requiere iniciar un nuevo despliegue desde el panel del
servicio mediante la opción de despliegue manual. Ese comportamiento resulta adecuado para un
dashboard cuyo contenido cambia con poca frecuencia y evita que una modificación incompleta se
publique de forma inmediata.

## 5.4 Comportamiento del plan gratuito

El plan gratuito de Render suspende el servicio tras quince minutos sin recibir solicitudes y
lo reactiva con la siguiente visita, proceso que puede tardar cerca de un minuto. Una vez
activa, la aplicación
responde con normalidad, puesto que todos los datos se cargan en memoria al arrancar y las
figuras se construyen a partir de archivos de pocos megabytes. El archivo de mayor tamaño,
`caudales.csv`, ocupa cerca de 1,7 MB.

## 5.5 Datos publicados

La licencia del portal DHIME autoriza la descarga de los datos para uso personal y no
comercial, sin conceder derechos de redistribución. Por esa razón, el repositorio del dashboard
no contiene los archivos originales del IDEAM y publica únicamente la serie diaria
consolidada de caudal y los resultados agregados del análisis, que son los insumos mínimos
para reproducir las figuras. El procedimiento para descargar los archivos originales se
documenta en el repositorio del estudio original.
