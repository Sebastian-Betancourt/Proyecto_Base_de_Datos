# Proyecto_Base_de_Datos
1. Introducción
En este proyecto, se desarrolla un sistema de base de datos para la gestión de un cine, permitiendo el almacenamiento y consulta eficiente de información relacionada con clientes, películas, funciones, boletos y pagos. Se abordan aspectos clave como seguridad, auditoría, rendimiento y optimización de consultas, asegurando una implementación robusta y escalable.

1.1 Objetivo del Proyecto
El objetivo del proyecto es diseñar e implementar una base de datos eficiente y segura para la gestión de un cine. Se busca optimizar el almacenamiento y acceso a la información de clientes, funciones y transacciones, garantizando integridad, seguridad y buen rendimiento en las consultas y operaciones del sistema.

2. Modelado de Base de Datos y Diccionario de Datos
2.1 Modelo Conceptual
Representación visual de la base de datos mediante diagramas entidad-relación, definiendo las entidades (Clientes, Películas, Funciones, Boletos, Pagos) y sus relaciones.

2.2 Modelo Lógico
Transformación del modelo conceptual en un esquema lógico utilizando notación relacional.

2.3 Modelo Físico
Definición del modelo de implementación en SQL, incluyendo estructuras de tablas, claves primarias y foráneas.

2.4 Diccionario de Datos
Descripción detallada de cada campo en las tablas, especificando nombres, tipos de datos, restricciones y relaciones.

2.5 Restricciones de Integridad
Definición de restricciones de clave primaria, clave foránea, unicidad y reglas de validación para mantener la coherencia de los datos.

3. Seguridad, Auditoría y Control de Acceso
3.1 Políticas de Seguridad y Acceso
Definición de roles y permisos para usuarios con diferentes niveles de acceso.

3.2 Cifrado de Datos Sensibles
Aplicación de técnicas de cifrado para proteger información confidencial, como datos de clientes y transacciones.

3.3 Auditoría y Registro de Eventos
Implementación de logs para registrar actividades en la base de datos y detectar accesos no autorizados.

4. Respaldos y Recuperación de Datos
4.1 Respaldo Completo
Copia de seguridad de toda la base de datos en intervalos definidos.

4.2 Respaldo Incremental
Almacenamiento de solo los cambios realizados desde el último respaldo.

4.3 Respaldo en Caliente
Estrategia para realizar copias de seguridad sin interrumpir el servicio.

5. Optimización y Rendimiento de Consultas
5.1 Creación y Gestión de Índices
Uso de índices para acelerar consultas en tablas con grandes volúmenes de datos.

5.2 Optimización de Consultas SQL
Mejoras en la escritura de consultas para reducir tiempos de respuesta.

5.3 Particionamiento de Tablas
División de tablas grandes para mejorar el acceso y la eficiencia en la ejecución de consultas.

6. Procedimientos Almacenados, Vistas y Triggers
6.1 Procedimientos Almacenados
Automatización de operaciones repetitivas con procedimientos en SQL.

6.2 Creación y Uso de Vistas
Definición de vistas para facilitar el acceso a datos específicos sin afectar la estructura de las tablas.

6.3 Implementación de Triggers
Uso de triggers para ejecutar acciones automáticas en respuesta a eventos dentro de la base de datos.

7. Monitoreo y Optimización de Recursos
7.1 Pruebas de Carga y Estrés
Evaluación del rendimiento de la base de datos bajo diferentes condiciones de uso.

7.2 Gestión de Índices y Recursos
Mantenimiento y optimización de índices para mejorar la eficiencia del sistema.

8. Git y Control de Versiones
8.1 Configuración del Repositorio
Creación y configuración de un repositorio GitHub para la gestión del código.

8.2 Estrategias de Versionado y Colaboración
Definición de flujo de trabajo para la colaboración en equipo, manejo de versiones y resolución de conflictos.
Nota: En nuestro caso, los archivos se compartieron por WhatsApp, asignando tareas a cada miembro y enviando avances según lo acordado.

8.3 Automatización de Pruebas
Investigación sobre integración continua para bases de datos y cómo aplicar GitHub Actions para automatizar pruebas de consultas SQL.

9. Conclusiones y Recomendaciones
Se concluye que la implementación de la base de datos para el cine permite gestionar eficientemente la información de clientes, funciones y transacciones, garantizando seguridad, rendimiento y escalabilidad. Se recomienda mejorar la automatización de procesos y considerar el uso de herramientas de control de versiones en futuros proyectos para mejorar la colaboración en equipo.
