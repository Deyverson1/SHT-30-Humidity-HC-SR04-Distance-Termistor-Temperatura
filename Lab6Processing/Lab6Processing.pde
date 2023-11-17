import processing.serial.*;
Sensor sensorTemperatura;
Sensor voltimetro;
Sensor humedad;
FechayHora fecha;
int lastSecond = 0;
String rawData;
float valorTemp;
float valorDistance;
float valorHumedad;
Serial myPort;  // Declarar la variable myPort

void setup() {
  size(1200, 700);
  String portName = "YourPort"; // Cambia esto al puerto que estés usando
  myPort = new Serial(this, portName, 9600);
  
  sensorTemperatura = new Sensor(180, 370, 200, 287, TIPO_MEDICION.LINEAL_VERTICAL);
  sensorTemperatura.setValorMinimoMedido(0);
  sensorTemperatura.setValorMaximoMedido(50);
  sensorTemperatura.setCoordXInicioIndicador(313);
  sensorTemperatura.setCoordYInicioIndicador(220);
  sensorTemperatura.setValorMedido(0);
  sensorTemperatura.setColorIndicador(color(255, 0, 0));
  sensorTemperatura.setValorAnchoIndicador(24);
  sensorTemperatura.setAlturaMax(180);
  
  voltimetro = new Sensor(500, 350, 220, 400, "regla2.png", TIPO_MEDICION.LINEAL_VERTICAL);
  voltimetro.setValorMinimoMedido(0);
  voltimetro.setValorMaximoMedido(10);
  voltimetro.setCoordXInicioIndicador(599);
  voltimetro.setCoordYInicioIndicador(350);
  voltimetro.setValorMedido(0);
  voltimetro.setColorIndicador(color(255, 0, 0));
  voltimetro.setValorAnchoIndicador(5);
  voltimetro.setAlturaMax(247);
  
  humedad = new Sensor(800, 400, 280, 257, "hola.jpeg", TIPO_MEDICION.RADIAL);
  humedad.setValorMinimoMedido(22);
  humedad.setValorMaximoMedido(72);
  humedad.setColorIndicador(color(255, 0, 0));
  humedad.setValorAnchoIndicador(10);
  humedad.setCoordXInicioIndicador(940);
  humedad.setCoordYInicioIndicador(530);
  humedad.setAlturaMax(90);
  
  fecha = new FechayHora(580, 10);
}

void draw() {
  background(255);
  fill(0);
  textSize(30);
  text("Laboratorio #6 Sensores: ", 600, 70);
  fecha.Dibujar();
  if (rawData != null) {
    String[] data = rawData.split(",");
    if (data.length == 3) {
      float distancia = float(data[0]);
      float temperatura = float(data[1]);
      float humedadvalue = float(data[2]);
      valorTemp = temperatura;
      valorDistance = distancia;
      valorHumedad = humedadvalue;
    } else {
      
    }
     
  }
   sensorTemperatura.setValorMedido(valorTemp);
      voltimetro.setValorMedido(valorDistance);
      humedad.setValorMedido(valorHumedad);
  float boxWidth = 800;
  float boxHeight = 120;

  // Posición del cuadro
  float boxX = 200;
  float boxY = 150;

  // Establecer el color del cuadro
  fill(255); // Color blanco

  // Dibujar el cuadro
  rect(boxX, boxY, boxWidth, boxHeight);

  // Establecer el color y el tamaño del texto
  textSize(30);
  fill(255, 165, 0); // Color para la temperatura

  // Establecer la alineación del texto en el centro del cuadro
  textAlign(CENTER, CENTER);

  // Mostrar la temperatura dentro del cuadro
  text("Temperatura: " + valorTemp + " °C", boxX + boxWidth / 2, boxY + boxHeight / 4);

  // Repetir el proceso para la distancia y la humedad
  fill(139, 69, 19); // Color para la distancia
  text("Distancia: " + valorDistance + " cm", boxX + boxWidth / 2, boxY + boxHeight / 2);

  fill(135, 206, 250); // Color para la humedad
  text("Humedad: " + valorHumedad + " %", boxX + boxWidth / 2, boxY + 3 * boxHeight / 4);
      sensorTemperatura.Dibujar();
      voltimetro.Dibujar();
      humedad.Dibujar();
      
      textSize(30);
      fill(255,165,0);
      text("Temperatura", 300, 360);
      textSize(30);
      fill(139,69,19);
      text("Distancia", 600, 330);
      textSize(30);
      fill(135,206,250);
      text("Humedad", 940, 370);
}

void serialEvent(Serial myPort) {
  rawData = myPort.readStringUntil('\n');
  if (rawData != null) {
    rawData = rawData.trim();  // Elimina espacios en blanco al principio y al final
  }
}
enum TIPO_MEDICION {
  LINEAL_VERTICAL,
  RADIAL
}

class Sensor implements Dibujo {
  float X;
  float Y;
  float ancho;
  float altura;
  String nombreArchivoImagen;
  PImage imagen;
  TIPO_MEDICION tipoMedicion;
  float valorMedido;

  float alto;
  float valorMinimoMedido = 0;
  float valorMaxMedido = 50;
  float porcentajeValorMedido = 0;

  float alturaMax = 100;

  float coordXInicioIndicador = 0;
  float coordYInicioIndicador = 0;
  float anchoIndicador = 35;
  color colorIndicador = color(0);

  float valorReferencialRadialInicial = -134;
  float valorReferencialRadialFinal = -49;

  Sensor(float coordX, float coordY, float ancho, float altura, TIPO_MEDICION tipoMedicion) {
    this.X = coordX;
    this.Y = coordY;
    this.ancho = ancho;
    this.altura = altura;
    nombreArchivoImagen = "termometro.jpg";
    imagen = loadImage(nombreArchivoImagen);
    this.tipoMedicion = tipoMedicion;
  }

  Sensor(float coordX, float coordY, float ancho, float altura, String nombreArchivoImagen, TIPO_MEDICION tipoMedicion) {
    this.X = coordX;
    this.Y = coordY;
    this.ancho = ancho;
    this.altura = altura;
    this.nombreArchivoImagen = nombreArchivoImagen;
    imagen = loadImage(nombreArchivoImagen);
    this.tipoMedicion = tipoMedicion;
  }

  void setValorReferencialRadialInicial(float valorReferencialRadialInicial) {
    this.valorReferencialRadialInicial = valorReferencialRadialInicial;
  }

  void setValorReferencialRadialFinal(float valorReferencialRadialFinal) {
    this.valorReferencialRadialFinal = valorReferencialRadialFinal;
  }

  void setValorAnchoIndicador(float anchoIndicador) {
    this.anchoIndicador = anchoIndicador;
  }

  void setValorMinimoMedido(float valMin) {
    this.valorMinimoMedido = valMin;
  }

  void setValorMaximoMedido(float valMax) {
    this.valorMaxMedido = valMax;
  }

  void setTipoMedicion(TIPO_MEDICION tipoMedicion) {
    this.tipoMedicion = tipoMedicion;
  }

  void setColorIndicador(color colorIndicador) {
    this.colorIndicador = colorIndicador;
  }

  void setAlturaMax(float alturaMax) {
    this.alturaMax = alturaMax;
  }

  void setValorMedido(float valorMedido) {
    this.valorMedido = valorMedido;
    porcentajeValorMedido = ((this.valorMedido) / valorMaxMedido);
  }

  void setCoordXInicioIndicador(float coordXInicioIndicador) {
    this.coordXInicioIndicador = coordXInicioIndicador;
  }

  void setCoordYInicioIndicador(float coordYInicioIndicador) {
    this.coordYInicioIndicador = coordYInicioIndicador;
  }

  void Dibujar() {
    image(imagen, X, Y, ancho, altura);
    fill(colorIndicador);
    if (this.tipoMedicion == TIPO_MEDICION.LINEAL_VERTICAL) {
      rect(this.coordXInicioIndicador, this.Y + altura - 80, anchoIndicador, - (alturaMax * porcentajeValorMedido));
    } else if (this.tipoMedicion == TIPO_MEDICION.RADIAL) {
      float angulo = map(this.valorMedido, this.valorMinimoMedido, this.valorMaxMedido, this.valorReferencialRadialInicial, this.valorReferencialRadialFinal) * (PI / 180);
      stroke(colorIndicador);
      strokeWeight(anchoIndicador);
      line(this.coordXInicioIndicador, this.coordYInicioIndicador, this.coordXInicioIndicador + cos(angulo) * alturaMax, this.coordYInicioIndicador + sin(angulo) * alturaMax);
    }
  }

  boolean ValidarClick(float mouseClickX, float mouseClickY) {
    return false;
  }
}
interface Dibujo {
  void Dibujar();
  boolean ValidarClick(float mouseClickX, float mouseClickY);
}

class FechayHora implements Dibujo {
  int ultimoSegundo = 0;
  float X;
  float Y;

  FechayHora(float coordenadaX, float coordenadaY) {
    this.X = coordenadaX;
    this.Y = coordenadaY;
  }

  void Dibujar() {
    int d = day();
    int y = year();
    int m = month();
    int h = hour();
    int mm = minute();
    int s = second();
    fill(0);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(d + "/" + m + "/" + y + " " + h + ":" + mm + ":" + s, X, Y);
    ultimoSegundo = s;
  }

  boolean ValidarClick(float mouseClickX, float mouseClickY) {
    return false;
  }
}
