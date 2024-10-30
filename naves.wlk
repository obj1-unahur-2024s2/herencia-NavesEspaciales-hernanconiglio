class Nave {
  var velocidad
  var direccion
  var combustible

  method initialize() {
    if (!velocidad.between(0, 100000) ||
      !direccion.between(-10,10)) 
      self.error("No se puede instanciar")
  }

  method cargarCombustible(cuanto) {
    combustible += cuanto
  }

  method desCargarCombustible(cuanto) {
    combustible = 0.max(combustible -cuanto)
  }


  method acelerar(cuanto) {
    velocidad = 100000.min(velocidad + cuanto)
    //también (velocidad + cuanto).min(100000)
  }

  method desacelerar(cuanto) {
    velocidad = 0.max(velocidad - cuanto)
  }

  method irHaciaElSol() {direccion=10}
  method escaparDelSol() {direccion=-10}
  method ponerseParaleloAlSol() {direccion=0}

  method acercarseUnPocoAlSol() {
    direccion = 10.min(direccion + 1)
  }

  method alejarseUnPocoAlSol() {
    direccion = -10.max(direccion - 1)
  }

  method prepararViaje() {
    self.cargarCombustible(30000)
    self.acelerar(5000)
    self.accionAdicional()
  }

  method accionAdicional()

  method estaTranquila() {
    return combustible >= 4000 && velocidad <= 12000
  }

  method recibirAmenaza() {
    self.escapar()
    self.avisar()
  }

  method escapar()
  method avisar()
  method estaDeRelajo() { return
    self.estaTranquila() && self.tienePocaActividad()
  }
  method tienePocaActividad() = true
}

class NaveBaliza inherits Nave {
  var baliza 
  var cambioDeColor
  const coloresValidos = #{"verde","rojo","azul"}

  method initialize() {
    cambioDeColor = false
    baliza = "verde"
  }
  method cambiarColorDeBaliza(colorNuevo) {
    if(!coloresValidos.contains(colorNuevo))
      self.error("el color nuevo no es válido")

    baliza = colorNuevo
    cambioDeColor = true
  }

  override method accionAdicional() {
    self.cambiarColorDeBaliza("verde")
    self.ponerseParaleloAlSol()
  }

  override method estaTranquila() {
    return super() && baliza != "rojo"
  }

  override method escapar() {self.irHaciaElSol()}
  override method avisar() {self.cambiarColorDeBaliza("rojo")}
  override method tienePocaActividad() = !cambioDeColor
}

class NaveDePasajeros inherits Nave {
  const pasajeros
  var comida
  var bebida
  var racionesServidas = 0

  method cargarComida(cuanto) {comida += cuanto}
  method cargarBebida(cuanto) {bebida += cuanto}
  method descargarComida(cuanto) {
    comida = 0.max(comida - cuanto)
    racionesServidas = (racionesServidas + cuanto).min(comida)
    }
  method descargarBebida(cuanto) {bebida = 0.max(bebida - cuanto)}
  override method accionAdicional() {
    self.cargarComida(4*pasajeros)
    self.cargarBebida(6*pasajeros)
    self.acercarseUnPocoAlSol()
  }
  override method escapar() {self.acelerar(velocidad)}
  override method avisar() {
    self.descargarComida(pasajeros)
    self.descargarBebida(pasajeros * 2)
  }
  override method tienePocaActividad() = racionesServidas < 50
}

class NaveHospital inherits NaveDePasajeros {
  var quirofanosPreparados = false
  method quirofanosPreparados() = quirofanosPreparados
  method alternarPrepararQuirofanos() {quirofanosPreparados=!quirofanosPreparados}

  override method estaTranquila() {
    return super() && !quirofanosPreparados
  }

  override method recibirAmenaza() {
    super()
    quirofanosPreparados = true
  }
}

class NaveDeCombate inherits Nave {
  var estaInvisible = false
  var misilesDesplegados = false
  const property mensajesEmitidos = []
  method ponerseVisible() {estaInvisible = false}
  method ponerseInvisible() {estaInvisible = true}
  method estaInvisible() = estaInvisible
  method desplegarMisiles() {misilesDesplegados=true}
  method replegarMisiles() {misilesDesplegados=false}
  method misilesDesplegados() = misilesDesplegados

  method emitirMensaje(mensaje) {
    mensajesEmitidos.add(mensaje)
  }

  method primerMensajeEmitido() {
    if(mensajesEmitidos.isEmpty()) self.error("no se emitieron mensajes")
    return mensajesEmitidos.first()
  }
  method ultimoMensajeEmitido() {
    if(mensajesEmitidos.isEmpty()) self.error("no se emitieron mensajes")
    return mensajesEmitidos.last()
  }

  method emitioMensaje(mensaje) = mensajesEmitidos.contains(mensaje) 

  method esEscueta() = mensajesEmitidos.all(
    { m => m.length() <= 30 }
  )

  override method accionAdicional() {
    self.ponerseVisible()
    self.replegarMisiles()
    self.acelerar(15000)
    self.emitirMensaje("Saliendo en misión")
  }

  override method estaTranquila() {
    return super() && !misilesDesplegados
  }

  override method escapar() {
    self.acercarseUnPocoAlSol()
    self.acercarseUnPocoAlSol()
  }

  override method avisar() {
    self.emitirMensaje("Amenaza recibida")
  }

}

class NaveSigilosa inherits NaveDeCombate {
  override method estaTranquila() {
    return super() && !estaInvisible
  }
  override method escapar() {
    super()
    self.desplegarMisiles()
    self.ponerseInvisible()
  }
}