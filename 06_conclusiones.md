# 6. Conclusiones

El dashboard reúne en tres pestañas el contexto, el análisis exploratorio y el modelo base de
un estudio que evalúa la posibilidad de anticipar con quince días de antelación los días en
que el río Magdalena se sitúa en el rango de descarga efectiva en la estación Calamar. La
ejecución del código expuesto en este informe reproduce las cifras que el dashboard presenta a
partir de la serie diaria de caudales, lo que confirma que los resultados precalculados que
emplea la aplicación corresponden al análisis documentado.

El análisis exploratorio estableció las condiciones bajo las cuales el problema puede
plantearse. La serie de transporte publicada por el IDEAM resultó ser una transformación
determinista del caudal, con ecuaciones que cambiaron varias veces a lo largo del registro,
por lo que se excluyó como predictor y como objetivo. El análisis magnitud-frecuencia situó la
descarga efectiva en 9.954 m³/s, valor que se excede en el 15,7 % de los días del periodo de
entrenamiento, y la banda de ±15 % a su alrededor definió una clase positiva del 25,7 %. Los
faltantes responden principalmente a la instalación progresiva de la red, y los huecos
internos que dependen del caudal se concentran en aguas bajas, lejos de la banda de interés.

La dependencia temporal condicionó el diseño de la evaluación. La autocorrelación de 0,918 a
quince días obligó a emplear una partición cronológica con intervalo de separación y una
validación cruzada temporal, y convirtió a la persistencia en la referencia exigente. Los
tiempos de tránsito estimados por correlación cruzada, de 7 a 21 días, guardan una relación
estrecha con la altitud y la latitud de las estaciones, lo que respalda su interpretación
física y justifica que cada estación entre al modelo desplazada según su tránsito.

La regresión logística alcanza un accuracy de 0,882 en el periodo de prueba, equivalente al
de la persistencia, de modo que esa métrica no distingue al modelo de una regla que repite el
estado actual. El PR-AUC, de 0,872 frente a 0,642 de la persistencia, muestra en cambio una
ventaja que alcanza su máximo precisamente en el horizonte de quince días. El modelo detecta
el 93,7 % de los días de transporte dominante con una precisión de 0,695, balance que
favorece la anticipación a costa de falsas alarmas y que puede ajustarse mediante el umbral
de decisión según el costo de cada tipo de error.

Los datos disponibles sugieren, sin embargo, que esa capacidad depende de las variables de
dominio que miden la distancia del caudal a la descarga efectiva. Sin ellas, el modelo lineal
se estanca en un PR-AUC cercano a 0,48 en todos los horizontes, porque una frontera lineal no
representa la pertenencia a una banda de caudales. El sobreajuste detectado en la validación
cruzada, de cuatro puntos porcentuales de ROC-AUC, resulta leve. La limitación de forma
funcional constituye, por lo tanto, la principal restricción del modelo base y orienta la
evaluación de clasificadores no lineales que aprendan la banda directamente de los
predictores.

En el plano de la implementación, la separación entre el cálculo de los resultados y su
presentación permitió desplegar el dashboard en el plan gratuito de Render con cinco
dependencias, sin redistribuir los archivos originales del IDEAM y con un tiempo de respuesta
que solo se ve afectado por la reactivación del servicio tras un periodo de inactividad.

## Referencias

Andrews, E. D. (1980). Effective and bankfull discharges of streams in the Yampa River
basin, Colorado and Wyoming. *Journal of Hydrology*, 46(3-4), 311-330.

Dickey, D. A., y Fuller, W. A. (1979). Distribution of the estimators for autoregressive
time series with a unit root. *Journal of the American Statistical Association*, 74(366),
427-431.

Emmett, W. W., y Wolman, M. G. (2001). Effective discharge and gravel-bed rivers. *Earth
Surface Processes and Landforms*, 26(13), 1369-1380.

IDEAM. (2026). *Sistema de Información Ambiental de Colombia. Consulta y descarga de datos
hidrometeorológicos (DHIME)*. http://dhime.ideam.gov.co

Kwiatkowski, D., Phillips, P. C. B., Schmidt, P., y Shin, Y. (1992). Testing the null
hypothesis of stationarity against the alternative of a unit root. *Journal of
Econometrics*, 54(1-3), 159-178.

Mann, H. B., y Whitney, D. R. (1947). On a test of whether one of two random variables is
stochastically larger than the other. *The Annals of Mathematical Statistics*, 18(1), 50-60.

Milliman, J. D., y Syvitski, J. P. M. (1992). Geomorphic/tectonic control of sediment
discharge to the ocean: the importance of small mountainous rivers. *The Journal of
Geology*, 100(5), 525-544.

Nash, D. B. (1994). Effective sediment-transporting discharge from magnitude-frequency
analysis. *The Journal of Geology*, 102(1), 79-95.

Pedregosa, F., Varoquaux, G., Gramfort, A., Michel, V., Thirion, B., Grisel, O., Blondel,
M., Prettenhofer, P., Weiss, R., Dubourg, V., Vanderplas, J., Passos, A., Cournapeau, D.,
Brucher, M., Perrot, M., y Duchesnay, É. (2011). Scikit-learn: Machine Learning in Python.
*Journal of Machine Learning Research*, 12, 2825-2830.

Plotly Technologies Inc. (2015). *Collaborative data science*. Plotly Technologies Inc.
https://plot.ly

Restrepo, J. D., y Kjerfve, B. (2000). Magdalena river: interannual variability (1975-1995)
and revised water discharge and sediment load estimates. *Journal of Hydrology*, 235(1-2),
137-149.

Restrepo, J. D., Kjerfve, B., Hermelin, M., y Restrepo, J. C. (2006). Factors controlling
sediment yield in a major South American drainage basin: the Magdalena River, Colombia.
*Journal of Hydrology*, 316(1-4), 213-232.

Restrepo, J. D., y Syvitski, J. P. M. (2006). Assessing the effect of natural controls and
land use change on sediment yield in a major Andean river: the Magdalena drainage basin,
Colombia. *AMBIO*, 35(2), 65-74.

Saito, T., y Rehmsmeier, M. (2015). The precision-recall plot is more informative than the
ROC plot when evaluating binary classifiers on imbalanced datasets. *PLoS ONE*, 10(3),
e0118432.

Seabold, S., y Perktold, J. (2010). Statsmodels: Econometric and statistical modeling with
Python. *Proceedings of the 9th Python in Science Conference*, 92-96.

Vargha, A., y Delaney, H. D. (2000). A critique and improvement of the CL common language
effect size statistics of McGraw and Wong. *Journal of Educational and Behavioral
Statistics*, 25(2), 101-132.

Wolman, M. G., y Miller, J. P. (1960). Magnitude and frequency of forces in geomorphic
processes. *The Journal of Geology*, 68(1), 54-74.
