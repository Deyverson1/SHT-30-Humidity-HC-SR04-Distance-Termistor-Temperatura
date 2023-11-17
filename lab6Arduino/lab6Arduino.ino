// libraries
#include <Wire.h>
#include <SHT31.h>
#include <WiFi.h>
#include <WiFiMulti.h>
#define Led1 17
#define OK 16
//inicio de wifi
WiFiMulti wifiMulti;
WiFiServer Servidor(80); //puerto de red
SHT31 sht;//inicio sensor

// Declaraciones de entrada // Pines
const int pinTrigger = 5; // contiene el valor del trigger del pin 0 del ESP32
const int termistorPin = 34; // contiene el valor del termistor del pin 2
const int pinEcho = 4; // contiene el valor del pin 4 del echo del HC-SR04

//termistor config
const double voltageReference = 3.3;                    //My voltage
const double R1 = 10000.0;                              //ohms valor del termistor
const double R2 = 10000.0;                              //Resitencias en serie
const double betaCoefficient = -4013.0;                 //coefficient beta ntc termistor
bool lecturasActivas = false;
double steinhart; 

uint8_t Val = 0x00;
String State26 = "Apagado"; //estado del led
String State27 = "Apagado"; //estado segundo led, en este caso no usado
float temperatura = 0.0; // Variable para almacenar la temperatura
float humedad = 0.0; //variable para almacenar humedad
float distance = 0.0; //variable para almacenar distancia 
//las variables anteriores son globales
//tiempo de la conexion
unsigned long TiempoActual = 0;
unsigned long TiempoAnterior = 0;
const long TiempoCancelacion = 500;

void setup() {
  // Inicio de comunicación
  Serial.begin(9600);

  // SHT-30
  Wire.begin();
  sht.begin(0x44);
  Wire.setClock(100000);
  uint16_t stat = sht.readStatus();
  Serial.print(stat, HEX);
  Serial.println();

  // HC-SR04 config
  pinMode(pinTrigger, OUTPUT);
  pinMode(pinEcho, INPUT);
  digitalWrite(pinTrigger, LOW);

  // Wifi
  pinMode(Led1, OUTPUT);
  pinMode(OK, OUTPUT);
  digitalWrite(OK, LOW);
  wifiMulti.addAP("Wifiname", "Password");    //red
  WiFi.mode(WIFI_STA);
  while (wifiMulti.run() != WL_CONNECTED) {   //si no se conecta se printan ..........
  Serial.print(".");
  };
  Serial.println("...Conectado");
  digitalWrite(OK, HIGH);
  Serial.println(WiFi.localIP());
  Servidor.begin();
  //wifi end
}
                  
void loop() {
  if (lecturasActivas){
      // HC-SR04 config end
      // termistor config start
      int rawValue = analogRead(termistorPin); // Lee el valor analógico
      double voltage = (rawValue / 4095.0) * voltageReference;                                    // Convierte el valor a tensión                                                                   
      double resistance = (R1 * R2 * voltage) / (R1 * voltageReference - R2 * voltage);           // Calcula la resistencia del termistor utilizando el divisor de voltaje
                                                                              // Calcula la temperatura en grados Celsius utilizando la ecuación de Steinhart-Hart
      steinhart = resistance / R1;                                                                // (R/R0)
      steinhart = log(steinhart);                                                                 // ln(R/R0)
      steinhart /= betaCoefficient;                                                               // 1/B * ln(R/R0)
      steinhart += 1.0 / (25 + 273.15);                                                           // + 1/(T0 + 273.15)
      steinhart = 1.0 / steinhart;                                                                // Invierte
      steinhart -= 273.15;                                                                        // Convierte a grados Celsius
      //termistor config end
      temperatura = steinhart;
        // HC-SR04 config
      unsigned long t;                            //tiempo en que toma la señal en ir y venir
      float d;                                    //valor de la distancia en cm
      digitalWrite(pinTrigger, HIGH);             //se pone en alto pin trigger
      delayMicroseconds(10);                      //espera para conseguir otro pulso
      digitalWrite(pinTrigger, LOW);              //se pone en bajo el pin trigger
      t = pulseIn(pinEcho, HIGH);                 //se mide el tiempo       
      d = t * 0.000001 * 34300.0 / 2.0;           //Se obtiene la distancia
      distance = d;
      // Serial.print(d);
      // HC-SR04 config loop end
      sht.read();
      humedad = sht.getHumidity(), 1;
      // Control prints~
      Serial.print(d);
      Serial.print(",");
      Serial.print(steinhart);//termistor
      Serial.print(",");
      Serial.print(humedad);
      Serial.println("");
      delay(1000);

  }
  WiFiClient cliente = Servidor.available();
  if (cliente) {
    TiempoActual = millis();
    TiempoAnterior = TiempoActual;
    String LineaActual = "";
    while (cliente.connected() && (TiempoActual - TiempoAnterior <= TiempoCancelacion)) {
      if (cliente.available()) {
        TiempoActual = millis();
        char Letra = cliente.read();
        if (Letra == '\n') {
          if (LineaActual.length() == 0) {
            Responder(cliente);
            break;
          } else {
            Verificar(LineaActual);
            LineaActual = "";
          }
        } else if (Letra != '\r') {
          LineaActual += Letra;
        }
      }
    }
    cliente.stop();
  }
}

bool lecturasActivasAnterior = false;


void Verificar(String Mensaje) {
  if (Mensaje.indexOf("GET /on1") >= 0) {
    Val |= 0x01;
    // lecturasActivas = true;
    // delay(1000);
    if (!lecturasActivasAnterior) {
      lecturasActivas = true;

      // Agregar un tiempo de espera para que las lecturas se estabilicen
      // delay(1000); // Esperar 1 segundo
    }
    Serial.println(Val);
    digitalWrite(Led1, HIGH);
    State26 = "Encendido";
  } else if (Mensaje.indexOf("GET /off1") >= 0) {
    Val &= 0xFE;
    Serial.println(Val);
    digitalWrite(Led1, LOW);
    State26 = "Apagado";
    steinhart = 0.0;
    humedad = 0.0;
    distance = 0.0;
    lecturasActivas = false;
      Serial.print(0);
      Serial.print(",");
      Serial.print(0);//termistor
      Serial.print(",");
      Serial.print(0);
      Serial.println("");
  }
}


void Responder(WiFiClient &cliente) {
  cliente.println("HTTP/1.1 200 OK");
  cliente.println("Content-Type: text/html");
  cliente.println("Connection: close");
  cliente.println();
  cliente.println("<!DOCTYPE html><html>");
  cliente.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
  cliente.println("<link rel=\"icon\" href=\"data:,\">");
  cliente.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}");
  cliente.println(".button { background-color: #008000; border: none; color: white; padding: 16px 40px;");
  cliente.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
  cliente.println(".button2 {background-color: #FF0000;}");
  cliente.println(".paragraph {color: white; padding-top: 1rem;}");
  cliente.println(".paragraph3 {color: white; }");
  cliente.println(".image {background-color: #202020; background-size: cover;}");
  cliente.println(".divButtons {display: flex; justify-content: center; align-items: center;}");
  cliente.println(".paragraph2 {color: white}</style></head>");
  cliente.println("<body class=\"image\"><h1 class=\"paragraph2\">Panel Web de control</h1>");
  cliente.print("<p class=\"paragraph2\">Conexion establecida");
  cliente.println(" <div class=\"divButtons\"> <p><a href=\"/on1\"><button class=\"button\">Start</button></a></p> <a href=\"/off1\"><button class=\"button button2\">Stop</button></a></p> </div> ");
  // cliente.println("<p>");
  cliente.print("<p class=\"paragraph\">Temperatura (°C): ");
  cliente.print(steinhart);
  cliente.print("<p class=\"paragraph2\">Humedad (%): ");
  cliente.print(humedad);
  cliente.print("<p class=\"paragraph3\">Distancia (cm): ");
  cliente.print(distance);
  if (lecturasActivas == true) {
    cliente.println("<meta http-equiv='refresh' content='1'>"); // Recargará la página cada 1 segundo
  }
  cliente.println("</html>");
}
