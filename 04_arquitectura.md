# 4. Arquitectura del dashboard

El dashboard es una aplicación de Dash contenida en un único archivo, `src/app.py`, que carga
resultados precalculados, construye las figuras con Plotly y organiza el contenido en tres
pestañas mediante componentes de Dash Bootstrap Components. Este capítulo describe la
estructura del repositorio, la separación entre el cálculo y la presentación, y el
funcionamiento de las funciones de retorno que dotan de interactividad a la aplicación.

## 4.1 Estructura del repositorio

El repositorio del dashboard contiene dos scripts de cálculo en la raíz, la aplicación y sus
datos en la carpeta `src`, y los archivos que Render requiere para el despliegue.

```text
Dashboard_Magdalena_ML/
├── exportar_eda.py
├── exportar_modelo.py
├── render.yaml
├── requirements.txt
└── src/
    ├── app.py
    └── datos/
        ├── caudales.csv
        ├── ubicaciones.csv
        ├── parametros.json
        ├── auditoria_transporte.csv
        ├── faltantes_mecanismo.csv
        ├── estacionariedad.json
        ├── fuga.csv
        ├── verificacion.csv
        ├── metricas.csv
        ├── roc.csv
        ├── pr.csv
        ├── confusion.csv
        └── horizonte.csv
```

## 4.2 Separación entre cálculo y presentación

Los resultados del análisis exploratorio y del modelo se calculan una sola vez, fuera de la
aplicación, y se guardan como archivos CSV y JSON en `src/datos`. El script
`exportar_eda.py` produce la auditoría de la serie de transporte, el diagnóstico del mecanismo
de los faltantes, las pruebas de estacionariedad con la función de autocorrelación, la
auditoría de fuga y la tabla de verificación por horizonte. El script `exportar_modelo.py`
entrena el modelo base y guarda las métricas, las curvas ROC y precisión-exhaustividad, la
matriz de confusión y el desempeño por horizonte. Ambos scripts reproducen el código de los
capítulos 2 y 3 de este informe.

Esa separación responde a tres razones. La primera es de recursos, dado que el plan gratuito
de Render ofrece 512 MB de memoria y una fracción de procesador, de modo que entrenar el modelo
cada vez que se inicia el servicio prolongaría el arranque y podría agotar la memoria. La
segunda es de dependencias, puesto que la aplicación desplegada solo requiere Dash, Dash
Bootstrap Components, Plotly, pandas y Gunicorn, mientras que scikit-learn, SciPy y
statsmodels se emplean únicamente en los scripts de cálculo. La tercera es de licencia, ya que
la auditoría de la serie de transporte requiere los archivos originales del IDEAM, que no se
redistribuyen y que por lo tanto no pueden formar parte del repositorio desplegado.

Las curvas ROC y precisión-exhaustividad se submuestrean a cerca de trescientos puntos antes
de guardarse, procedimiento que reduce el tamaño de los archivos sin alterar visualmente la
forma de las curvas.

```python
fpr, tpr, _ = roc_curve(yte, ys)
prec, rec, _ = precision_recall_curve(yte, ys)
paso_r = max(1, len(fpr) // 300)
paso_p = max(1, len(prec) // 300)
pd.DataFrame({"fpr": fpr[::paso_r], "tpr": tpr[::paso_r]}).to_csv(DESTINO / "roc.csv", index=False)
pd.DataFrame({"precision": prec[::paso_p], "recall": rec[::paso_p]}).to_csv(DESTINO / "pr.csv", index=False)
```

## 4.3 Carga de datos

La aplicación lee todos los archivos al arrancar y los conserva en memoria durante la vida
del proceso. Las rutas se construyen a partir de la ubicación de `app.py`, de modo que la
aplicación encuentra sus datos con independencia del directorio desde el que se ejecute,
condición necesaria para el despliegue.

```python
DATOS = Path(__file__).parent / "datos"

caudales = pd.read_csv(DATOS / "caudales.csv", parse_dates=["fecha"])
ubicaciones = pd.read_csv(DATOS / "ubicaciones.csv", sep=";", encoding="utf-8-sig")
metricas = pd.read_csv(DATOS / "metricas.csv")
estacionariedad = json.loads((DATOS / "estacionariedad.json").read_text(encoding="utf-8"))
par = json.loads((DATOS / "parametros.json").read_text(encoding="utf-8"))

Q_EF = par["Q_EF"]
LIM = par["LIM"]
TRANSITOS = par["TRANSITOS"]
```

La aplicación se crea con la hoja de estilos de Bootstrap y expone el servidor de Flask
subyacente en la variable `server`, que Gunicorn emplea en producción.

```python
app = Dash(__name__,
           external_stylesheets=[dbc.themes.BOOTSTRAP],
           suppress_callback_exceptions=True,
           title="Descarga efectiva - Río Magdalena")
server = app.server
```

## 4.4 Funciones de figuras

Cada figura se genera en una función propia que devuelve un objeto de Plotly, de modo que el
código de las figuras queda separado de la disposición de la página. Las funciones
`fig_mapa`, `fig_faltantes`, `fig_cobertura`, `fig_magnitud_frecuencia`, `fig_estacional`,
`fig_duracion`, `fig_acf`, `fig_correlacion` y `fig_transito` corresponden a la pestaña de
análisis exploratorio y al mapa de la pestaña de contexto, mientras que `fig_roc`, `fig_pr`,
`fig_confusion` y `fig_horizonte` corresponden a la pestaña de modelos. Su contenido coincide
con el de las celdas de los capítulos 1 a 3. La función del análisis magnitud-frecuencia
ilustra el patrón común, que combina el cálculo sobre los datos cargados con la construcción
de la figura (Plotly Technologies Inc., 2015).

```python
def fig_magnitud_frecuencia():
    serie = caudales.loc[caudales.fecha < CORTE, "calamar"].dropna()
    bordes = np.logspace(np.log10(serie.min()), np.log10(serie.max()), 26)
    frec, _ = np.histogram(serie, bins=bordes)
    centros = np.sqrt(bordes[:-1] * bordes[1:])
    carga = frec * par["A_OF"] * centros ** par["B_OF"]

    fig = go.Figure()
    fig.add_trace(go.Bar(x=centros, y=100 * frec / frec.sum(), name="Frecuencia (% de días)",
                         marker_color="steelblue", opacity=0.6))
    fig.add_trace(go.Scatter(x=centros, y=100 * carga / carga.sum(),
                             name="Carga transportada (%)", mode="lines+markers",
                             line=dict(color="sienna", width=3)))
    fig.add_vline(x=Q_EF, line_dash="dash", line_color="red",
                  annotation_text=f"Q_ef = {Q_EF:,.0f} m³/s")
    fig.update_layout(xaxis_title="Clase de caudal (m³/s)", yaxis_title="Porcentaje",
                      height=430, margin=dict(t=30), legend=dict(orientation="h", y=1.1))
    return fig
```

La figura del tiempo de tránsito requiere relacionar el nombre de cada estación en el
catálogo del IDEAM con la clave de su serie de caudal. Una normalización automática de los
nombres convertía «PUERTO SALGAR - AUT» en `puerto_salgar`, clave que no coincide con
`pto_salgar`, y la estación desaparecía de la figura sin generar error. Por esa razón la
correspondencia se declara de forma explícita en un diccionario.

## 4.5 Componentes de presentación

La disposición de cada pestaña se construye con funciones auxiliares que encapsulan los
patrones repetidos. La función `tarjeta` genera los indicadores de la pestaña de contexto,
`parrafo` y `nota` producen texto justificado en tamaño normal y reducido, y `tabla`
convierte un DataFrame en una tabla de Bootstrap. La función `bloque` agrupa un título, una
figura y su interpretación en una tarjeta, y las funciones `seccion` y `acordeon` organizan
el contenido en secciones desplegables.

```python
def bloque(titulo, figura, interpretacion):
    return dbc.Card(dbc.CardBody([
        html.H5(titulo),
        dcc.Graph(figure=figura),
        nota(interpretacion),
    ]), className="mb-4")


def seccion(titulo, *contenido):
    return dbc.AccordionItem(list(contenido), title=titulo)


def acordeon(*secciones):
    return dbc.Accordion(list(secciones), start_collapsed=True, always_open=True,
                         className="mb-4")
```

El acordeón se inicia con todas sus secciones cerradas y permite mantener varias abiertas a
la vez. Esa configuración presenta al lector un índice de cada pestaña al cargarla y le
permite comparar resultados de secciones distintas sin perder el contexto. Las figuras que
interpretan resultados relacionados, como las curvas de evaluación, se disponen en pares
mediante filas y columnas de Bootstrap, que se apilan en una sola columna en pantallas
estrechas.

## 4.6 Pestañas y funciones de retorno

El diseño general de la página contiene un encabezado con el título, los autores y la
institución, un componente `dcc.Tabs` con las tres pestañas y un contenedor vacío cuyo
contenido se asigna según la pestaña seleccionada.

```python
dcc.Tabs(id="pestanas", value="contexto", children=[
    dcc.Tab(label="Contexto del problema", value="contexto"),
    dcc.Tab(label="Análisis exploratorio", value="eda"),
    dcc.Tab(label="Modelos base", value="modelos"),
]),

html.Div(id="contenido", className="mt-4"),
```

La aplicación define dos funciones de retorno. La primera recibe el valor de la pestaña
seleccionada y devuelve el contenido correspondiente, de modo que solo se construye la pestaña
visible. La segunda actualiza la serie de caudal de la pestaña de análisis exploratorio según
las estaciones elegidas en el selector, agrega los valores diarios a promedios mensuales y
sombrea la banda de descarga efectiva.

```python
@app.callback(Output("contenido", "children"), Input("pestanas", "value"))
def mostrar_pestana(pestana):
    if pestana == "contexto":
        return tab_contexto()
    elif pestana == "eda":
        return tab_eda()
    return tab_modelos()


@app.callback(Output("g-serie", "figure"), Input("sel-estaciones", "value"))
def actualizar_serie(estaciones):
    if not estaciones:
        return go.Figure()
    d = caudales.set_index("fecha")[estaciones].resample("MS").mean().reset_index()
    fig = px.line(d, x="fecha", y=estaciones,
                  labels={"value": "Caudal (m³/s)", "fecha": "Fecha",
                          "variable": "Estación"})
    fig.add_hrect(y0=LIM[0], y1=LIM[1], fillcolor="red", opacity=0.12, line_width=0)
    return fig
```

El selector y la figura de la serie se encuentran dentro de la pestaña de análisis
exploratorio, por lo que no existen en la página cuando se muestra otra pestaña. Dash valida
por defecto que todos los identificadores referidos en las funciones de retorno estén
presentes en el diseño inicial y, al no encontrarlos, emite el error «ID not found in
layout». La opción `suppress_callback_exceptions=True` desactiva esa validación, y la función
de retorno se ejecuta cuando la pestaña se carga y los componentes aparecen en la página. La
agregación mensual reduce la serie de más de treinta mil valores diarios a cerca de mil
puntos por estación, lo que mantiene fluida la respuesta del navegador.

## 4.7 Ejecución local

La aplicación se ejecuta localmente con el intérprete del entorno que contiene las
dependencias de `requirements.txt`. El servidor de desarrollo de Dash queda disponible en
`http://127.0.0.1:8050` y recarga la aplicación automáticamente cuando se modifica el código.

```bash
pip install -r requirements.txt
python src/app.py
```

Los scripts de cálculo se ejecutan una sola vez, antes de la aplicación, con un entorno que
incluya scikit-learn, SciPy y statsmodels.

```bash
python exportar_modelo.py
python exportar_eda.py
```
