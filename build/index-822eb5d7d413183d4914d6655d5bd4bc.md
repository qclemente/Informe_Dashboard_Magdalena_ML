# Descarga efectiva en el río Magdalena: informe del dashboard

*Kevin Clemente Rosario y Manuel Meza Castro*

Universidad del Norte

Machine Learning - 202630

Dashboard: [https://dashboard-magdalena.onrender.com](https://dashboard-magdalena.onrender.com)

Código del dashboard: [https://github.com/qclemente/Dashboard_Magdalena_ML](https://github.com/qclemente/Dashboard_Magdalena_ML)

---

## Presentación

Este informe documenta el desarrollo de un dashboard que reúne el contexto, el
análisis exploratorio y el modelo base de un estudio sobre la descarga efectiva del río
Magdalena en la estación Calamar. El dashboard se construyó con Dash y Plotly y se encuentra
desplegado en Render. El informe reproduce cada resultado que allí se presenta a partir de la
serie diaria de caudales, desarrolla su interpretación y añade los detalles metodológicos y de
implementación que el dashboard omite por razones de espacio.

La construcción de la base de datos, la estimación de la descarga efectiva y el diseño
original del modelo se documentan con mayor extensión en el libro [Proyecto de investigación:
descarga efectiva en el río Magdalena](https://qclemente.github.io/Proyecto_Magdalena_ML/). El
presente informe parte de la serie consolidada en ese trabajo y verifica que las cifras del
dashboard se obtienen de nuevo al ejecutar el código que aquí se expone.

## Pregunta de investigación

> ¿Es posible clasificar, con la información hidrológica disponible hasta el día $t$, si el
> día $t+15$ pertenecerá al rango de descarga efectiva del río Magdalena en la estación
> Calamar?

## Organización del informe

Los capítulos 1 a 3 siguen el orden de las tres pestañas del dashboard, de modo que cada
sección corresponde a una de sus secciones desplegables y contiene el código que produce la
figura o la tabla respectiva. Las figuras conservan la interactividad de Plotly, por lo que
admiten acercamiento y muestran sus valores al pasar el cursor. El capítulo 4 describe la
arquitectura de la aplicación y el capítulo 5 el proceso de despliegue en Render. El capítulo
6 reúne las conclusiones y las referencias.

Los notebooks de los capítulos 2 y 3 deben ejecutarse en ese orden, dado que el segundo
emplea la matriz de predictores que construye el primero. El servicio se aloja en el plan
gratuito de Render, que suspende la aplicación tras un periodo sin visitas, de manera que la
primera carga del dashboard puede demorar cerca de un minuto.
