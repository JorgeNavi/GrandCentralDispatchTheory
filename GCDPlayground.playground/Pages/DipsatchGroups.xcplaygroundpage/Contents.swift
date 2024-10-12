//: [Previous](@previous)

import Foundation

//vamos a crear dos colas concurrentes para ver el uso de DispatchGroups
struct SampleDispatchGroups {
    
    let lettersQueue = DispatchQueue(label: "io.keepcoding.lettersQueue", attributes: .concurrent) //El label actúa como descripción de la cola o su "nombre" para dar información a los desarrolladores sobre qué es lo que hace la cola. Aquí se ve la importancia de saber escoger de manera adecuada el nombre de las variables
    let indexesQueue = DispatchQueue(label: "io.keepcoding.indexesQueue", attributes: .concurrent) //hay que notificar el atributo current para que la cola sea concurrente (que las tareas se vayan ejecutando a la vez). Si no se especifica es una cola en serie (como la de arriba) en la que las tareas se van ejecutando de forma secuencial.
    let series = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"]
    let dispatchGroup = DispatchGroup() //instanciamos el DispatchGroup
    
    //Hacemos una funcion para añadir tareas a la cola de forma concurrente
    func testConcurrentTask() {
        
        for c in series {
            //avisamos al DispatchGroup de que entramos en una tarea
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave() como enter()
            lettersQueue.async {
                print("\(c)", terminator: "")
                self.dispatchGroup.leave()
            }
            //avisamos al DispatchGroup de que entramos en otra tarea
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave() como enter()
            indexesQueue.async {
                if let index = series.firstIndex(where: { $0 == c}) { //firstIndex(where:): Este es un método de las colecciones en Swift que busca el primer índice donde se cumple una condición especificada. La condición dentro del bloque { $0 == c } utiliza una clausura que compara cada elemento ($0) de la colección series con una variable c, donde C es cada elemento de la serie como indica el bucle for
                    print(index, terminator: "") //imprime el indice de $0 que equivalga a c, es decir, imprime los indices de los elementos en este caso. Terminator sirve para evitar el salto de línea
                }
                self.dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            print(" Finished")
        }
    }
    
    //DispatchGroup espera por cada ciclo
    func testConcurrentTaskWaitingEveryCycle() {
        
        for c in series {
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave() como enter()
            lettersQueue.async {
                print("\(c)", terminator: "")
                self.dispatchGroup.leave()
            }
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave() como enter()
            indexesQueue.async {
                if let index = series.firstIndex(where: { $0 == c}) {
                    print(index, terminator: "")
                }
                self.dispatchGroup.leave()
            }
            dispatchGroup.wait() //.wait() sirve para esperar a que se completen las tareas pendientes antes de ejecutar la siguiente. No tienen que ejecutarse en el orden secuencial en el que hemos hecho el código, pero si que, en este caso, espera a que se ejecuten las dos tareas (de lettersQueue e indexQueue) en cada iteracción del for antes de pasar a la siguiente.
        }
        dispatchGroup.notify(queue: .main) {
            print(" Finished")
        }
    }
    
    //vamos a provocar un "data race"
    func sampleDataRace(completion: @escaping (String) ->()) {
        
        var result = "" //vamos a guardar lo que imprimimos en la consola en esta variable
        
        for c in series {
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave() como enter()
            lettersQueue.async {
                print("\(c)", terminator: "")
                result = result + c //aqui y en result = result + "\(index)" es donde se produce el data race, intentando modificar el valor de la variable result de forma concurrente
                self.dispatchGroup.leave()
            }
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave() como enter()
            indexesQueue.async {
                if let index = series.firstIndex(where: { $0 == c}) {
                    print(index, terminator: "")
                    result = result + "\(index)" //aqui y en result = result + c es donde se produce el data race, intentando modificar el valor de la variable result de forma concurrente
                }
                self.dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            print(" Finished")
            completion(result)
        } //Lo que ocurre en esta funcion, es que al establecer la variable result para introducir el resultado de las dos tareas concurrentes, se va a estar intentando introducir la información de las dos tareas en la variable result al mismo tiempo, provocando que los datos se pisen unos a otros, lo que puede llevar a la pérdida de parte de la información. Esto es lo que se denomina "data race"
    }
    
    //vamos a solucionar un "data race" protegiendo el acceso a la variable result con una cola en serie y síncrona
    func sampleDataRaceSolved(completion: @escaping (String) ->()) {
        
        var result = "" //vamos a guardar lo que imprimimos en la consola en esta variable
        var serialQueue = DispatchQueue(label: "serialQueue") //instanciamos una cola en serie
        
        for c in series {
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave() como enter()
            lettersQueue.async {
                print("\(c)", terminator: "")
                serialQueue.sync { //de esta manera, al introducir el result en una cola en serie y de manera sincrona, bloquea la ejecución para que cuando ella acceda al recurso, nadie puede acceder al recurso hasta que lla termine, protegiendo la variable de sufrir data race
                    result = result + c
                }
                
                self.dispatchGroup.leave()
            }
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave() como enter()
            indexesQueue.async {
                if let index = series.firstIndex(where: { $0 == c}) {
                    print(index, terminator: "")
                    serialQueue.sync { //de esta manera, al introducir el result en una cola en serie y de manera sincrona, bloquea la ejecución para que cuando ella acceda al recurso, nadie puede acceder al recurso hasta que lla termine, protegiendo la variable de sufrir data race
                        result = result + "\(index)"
                    }
                    self.dispatchGroup.leave()
                }
            }
            
        }
        dispatchGroup.notify(queue: .main) {
            print(" Finished")
            completion(result)
        }
    }
}
    
var sampleDispatchGroups = SampleDispatchGroups()
//sampleDispatchGroups.testConcurrentTask()
//sampleDispatchGroups.testConcurrentTaskWaitingEveryCycle()
//sampleDispatchGroups.sampleDataRace { result in
//    print(result)
//}
    
sampleDispatchGroups.sampleDataRaceSolved { result in
    print(result)
}
