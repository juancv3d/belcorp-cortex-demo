# HISTORIA DE USUARIO FUNCIONAL

## 1. INFORMACION GENERAL

| Campo | Valor |
|-------|-------|
| TICKET DE NEGOCIO | DST-847 |
| EQUIPO SOLICITANTE | Comercial / Strategy & Finance |
| CONTACTO DE NEGOCIO | Product Owner: @Carolina Martinez |
| EQUIPO TECNICO | Tech Lead: @Pendiente de asignacion |
| TIPO DE REQUERIMIENTO | Analisis y Medicion de Impacto |
| FECHA CREACION | 15 Abr 2026 |

## 2. HISTORIA FUNCIONAL

### 2.1 Contexto (AS-IS)

Actualmente, el equipo comercial evalua el cumplimiento de metas de venta a nivel agregado por campana, sin distinguir por marca, categoria o pais. Esto limita la capacidad de identificar cuales combinaciones marca-categoria estan consistentemente por debajo del must-have y cuales superan la meta planificada.

Adicionalmente, no se cuenta con una vista consolidada que permita comparar el desempeno entre paises para una misma combinacion marca-categoria, lo que dificulta la identificacion de mejores practicas regionales.

### 2.2 Objetivo (TO-BE)

#### 2.2.1 Resultado Esperado

Generar un analisis de cumplimiento de metas de venta por marca, categoria y pais para las ultimas 6 campanas finalizadas, cruzando las metas planificadas (`METAS_CAMPANA`) contra las ventas reales (`VENTAS`), que permita:

- Identificar combinaciones marca-categoria con bajo cumplimiento sostenido
- Detectar paises con desempeno inferior al must-have
- Habilitar decisiones de ajuste en planificacion comercial

#### 2.2.2 Usuarios Objetivo

El equipo de Strategy & Finance y los Gerentes Comerciales por pais.

#### 2.2.3 Decision Habilitada

- Ajustar metas de campanas futuras en combinaciones con bajo cumplimiento historico
- Reasignar presupuesto comercial entre marcas y categorias
- Disenar estrategias diferenciadas por pais basadas en desempeno relativo

### 2.3 Criterios de Aceptacion

#### 2.3.1 Alcance del Analisis

| N | Pregunta a Responder | Periodo | Segmento del Alcance | Cortes Adicionales | Criterio de Exito |
|---|---------------------|---------|---------------------|--------------------|-------------------|
| 1 | Cual es el % de cumplimiento de venta planificada por marca-categoria en cada campana? | Ultimas 6 campanas | Marca, Categoria | Pais, Campana | Tabla con % cumplimiento por cruce |
| 2 | Cuantas combinaciones marca-categoria estan por debajo del must-have de venta? | Ultimas 6 campanas | Marca, Categoria, Pais | Campana | Conteo y listado de combinaciones criticas |
| 3 | Existe correlacion entre la estrategia de oferta predominante y el nivel de cumplimiento? | Ultimas 6 campanas | Estrategia de Oferta | Marca, Categoria | Correlacion identificada o descartada |
| 4 | Cuales paises presentan mejor y peor cumplimiento relativo respecto a sus metas? | Ultimas 6 campanas | Pais | Marca, Campana | Ranking de paises con insights accionables |

#### 2.3.2 Presentacion de Resultados

- [x] Query reproducible en Snowflake
- [x] Documento de analisis con hallazgos
- [x] Evidencia de validacion de datos

### 2.4 Medicion del Incremento de Valor

| Categoria | Metrica | Estrategia de Medicion | Criterio de Exito |
|-----------|---------|----------------------|-------------------|
| Value | Uso del analisis en ajuste de metas | Seguimiento de campanas con metas ajustadas | >= 1 ciclo de ajuste basado en el analisis |
| Speed | Tiempo de generacion del analisis | Comparacion vs proceso manual actual | Reduccion >= 50% |
| Quality | Precision del cruce metas vs ventas reales | Validacion cruzada con equipo de Finance | Variacion <= 1% vs fuente |
