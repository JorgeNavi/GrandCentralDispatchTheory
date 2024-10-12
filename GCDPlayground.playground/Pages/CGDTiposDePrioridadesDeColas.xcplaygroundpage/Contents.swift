//: [Previous](@previous)

import Foundation

//vamos a porbar las distintas prioridades de las colas (QoS: Quality of Services)
struct GlobalGCDQueues {
    
    //creamos una variable de tipo DispatchWorkItem que nos va a hacer falta para el asynAfter
    /* Un DispatchWorkItem es un bloque de código que puede ser enviado a una cola de DispatchQueue para ser ejecutado. Este bloque puede ser cualquier cosa que necesites ejecutar. El uso de DispatchWorkItem te da control adicional sobre las tareas en las colas de ejecución */
    var workItem: DispatchWorkItem?
    
    func performTask() {
        
        //vamos a usar la cola global que nos da el sistema para meterle prioridades
        //Normalmente se usa el valor por defecto
        
        
        // Cola de prioridad máxima para tareas relacionadas con la interacción directa con el usuario
        // Se usa para operaciones que deben ser instantáneas para mantener una interfaz fluida.
        DispatchQueue.global(qos: .userInteractive).async {
            print("Priority interactive")
        }

        // Cola de alta prioridad para tareas iniciadas por el usuario que requieren una respuesta rápida
        // No son inmediatas como las interacciones de usuario, pero sí son importantes para cargar elementos esperados.
        DispatchQueue.global(qos: .userInitiated).async {
            print("Priority UserInitiated")
        }

        // Cola de prioridad predeterminada para tareas que no requieren una prioridad específica
        // Utilizada para operaciones generales que no necesitan una respuesta inmediata.
        DispatchQueue.global(qos: .default).async {
            print("Priority default")
        }

        // Cola de baja prioridad para tareas de larga duración que el usuario no espera que se completen inmediatamente
        // Adecuada para procesos que pueden tomar tiempo, como descargas o procesos de sincronización.
        DispatchQueue.global(qos: .utility).async {
            print("Priority utility")
        }

        // Cola de la más baja prioridad para tareas que se ejecutan completamente en segundo plano
        // Ideal para tareas no urgentes como copias de seguridad o tareas de mantenimiento.
        DispatchQueue.global(qos: .background).async {
            print("Priority background")
        }
    }
    
    func testMainQueue() {
        DispatchQueue.main.async {
            print("Inside queue")
        }
        //esto se ejecuta antes que el inside queue por el hecho del async. Para asegurar que se ejecute antes el inside, deberiamos meter ese out en el bloque de codigo del DispatchQueue
        print("Out of Queue")
    }
    
    //vamos a poner un ejemplo de cómo o para que se usa el asyncAfter. esto puede sernos útil de cara a ala práctica, hacer le detalle de las transformaciones con una función que simula una busqueda de personas por nombre
    mutating func searchPerson(name: String) { //mutating para poder modificar los atributos del struct
        
        workItem?.cancel() //esto sirve para cancelar busquedas anteriores al deadline que establecemos para evitar ejecuciones superpuestas. "Me entra una búsqueda y, si existe(porque es un opcional, cancelo la anterior y creo la que me ha llegado ahora". Eviatmos que en un plazo anterior a 0.5 sec nos entren dos búsquedas simultáneas.
        
        workItem = DispatchWorkItem(block:
        {
            print("realizamos la búsqueda por \(name)")
        })
        
        if let workItem { //desempaquetamos el worItem
            //Los DispatchQueue se pueden usar con clousures o mediante el workItem (mirar en la variable de workItem para más info)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:  workItem)//DispatchQueue que se ejecuta en el hilo main. Despues de 0.5 sec desde now, me ejecutas workItem
            }
        }
        
}


        
var globalGCDQueues = GlobalGCDQueues()
//globalGCDQueues().performTask()
//globalGCDQueues.testMainQueue()

globalGCDQueues.searchPerson(name: "John")
//si una busqueda se lanza antes de 0.5, la anterior se cancela tal y como hemos establecido en la función
DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { //Esto es para simular que se ha realizado una búsqueda posterior, como se hace en menos de 0.5 sec (lo hemos puesto en 0.4), cancela la búsqueda de "John" y solo imprime la búsqueda de "Manuel"
    globalGCDQueues.searchPerson(name: "Manuel")
}
