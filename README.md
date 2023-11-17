# SHT-30-HC-SR04-Termistor
SHT-30-HC-SR04-Tersmistor Este repositorio contiene codoigo de Arduino y Processing para la medida correcta de los sensores SHT-30 (Humedad), HC-SR04 (Distancia), Termistor (NTC 203)  

Este fue realizado como laboratorio #6 en la clase de Sistemas Digitales Programables en Mecatronica Industrial .

Este proyecto consiste en la implementacion de tres sensores para la medida de Temperatura, Humedad y Distancia.

Por medio de una red movil a la cual se podra conectar nuestro ESP32 se generara una pagina desde la cual podremos controlar el funcionamiento de nuestra aplicacion.

# Conexiones 



## ¿Como utilizarlo?
1. Descarga los documentos del repositorio.
2. Entra en el archivo de Arduino.
3. Descarga las librerias necesarias. (Incluidas al inicio del archivo de Arduino)
4. Modifica la red.
5. Entra en la IP para ver el entorno web.
6. Entra en Processing (Cambia tu puerto)
7. Compila.

### Algunos de los errores comunes:
- Problemas con las medidas del termistor:
En algunos casos se soluciona cambiando de pin.
La resistencia utilizada debe ser igual a la del termistor

- Problemas con las medidas del HC-SR04
En algunos casos se presentan poblemas en el voltaje, en caso de tener todas las conexiones a 3.3v probar con 5v para el HC-SR04


# Contenido 100% educativo
