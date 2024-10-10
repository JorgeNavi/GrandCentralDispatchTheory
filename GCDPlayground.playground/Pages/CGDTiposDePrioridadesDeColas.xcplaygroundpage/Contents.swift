//: [Previous](@previous)

import Foundation

//vamos a porbar las distintas prioridades de las colas (QoS: Quality of Services)
struct GlobalGCDQueues {
    
    //creamos una variable de tipo DispatchWorkItem que nos va a hacer falta para el asynAfter
    var workItem: DispatchWorkItem?
    
    func performTask() {
        
        //vamos a usar la cola global que nos da el sistema para meterle prioridades
        //Normalmente se usa el valor por defecto
        
        
        //estas son para cosas muy rapidas como la interfaz
        DispatchQueue.global(qos: .userInteractive).async {
            print("Priority interactive")
        }
        
        //estas tambien son rapidas pero menos
        DispatchQueue.global(qos: .userInitiated).async {
            print("Priority UserInitiated")
        }
        
        DispatchQueue.global(qos: .default).async {
            print("Priority default")
        }
        
        DispatchQueue.global(qos: .utility).async {
            print("Priority utility")
        }
        
        //backgrouend son las mas pesadas, las menos prioritarias
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
    
    //vamos a poner un ejemplo de cómo o para que se usa el asyncAfter
    mutating func searchPerson(name: String) { //mutating para poder modificar los atributos del struct
        
        workItem?.cancel() //esto sirve para cancelar busquedas anteriores al deadline que establecemos
        
        workItem = DispatchWorkItem(block:
        {
            print("realizamos la búsqueda por \(name)")
        })
        
        if let workItem { //desempaquetamos el worItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute:  workItem)
            }
        }
        
}


        
var globalGCDQueues = GlobalGCDQueues()
//globalGCDQueues().performTask()
//globalGCDQueues.testMainQueue()

globalGCDQueues.searchPerson(name: "John")
//si una busqueda se lanza antes de 0.5, la anterior se cancela
DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { 
    globalGCDQueues.searchPerson(name: "Manuel")
}
