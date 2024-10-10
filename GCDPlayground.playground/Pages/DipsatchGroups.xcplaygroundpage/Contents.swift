//: [Previous](@previous)

import Foundation

//vamos a crear varias colas
struct SampleDispatchGroups {
    
    let lettersQueue = DispatchQueue(label: "io.keepcoding.lettersQueue", attributes: .concurrent)
    let indexesQueue = DispatchQueue(label: "io.keepcoding.indexesQueue", attributes: .concurrent)
    let series = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"]
    let dispatchGroup = DispatchGroup()
    
    
    //funcion para añadir tareas a la cola de forma concurrente
    
    func testConcurrentTask() {
        
        for c in series {
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave(9 como enter()
            lettersQueue.async {
                print("\(c)", terminator: "")
                self.dispatchGroup.leave()
            }
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave(9 como enter()
            indexesQueue.async {
                if let index = series.firstIndex(where: { $0 == c}) {
                    print(index, terminator: "")
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
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave(9 como enter()
            lettersQueue.async {
                print("\(c)", terminator: "")
                self.dispatchGroup.leave()
            }
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave(9 como enter()
            indexesQueue.async {
                if let index = series.firstIndex(where: { $0 == c}) {
                    print(index, terminator: "")
                }
                self.dispatchGroup.leave()
            }
            dispatchGroup.wait()
        }
        dispatchGroup.notify(queue: .main) {
            print(" Finished")
        }
    }
    
    //vamos a provocar un "ConditionRace"
    
    func sampleDataRace(completion: @escaping (String) ->()) {
        
        var result = "" //vamos a guardar lo que imprimimos en la consola en esta variable
        
        for c in series {
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave(9 como enter()
            lettersQueue.async {
                print("\(c)", terminator: "")
                result = result + c
                self.dispatchGroup.leave()
            }
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave(9 como enter()
            indexesQueue.async {
                if let index = series.firstIndex(where: { $0 == c}) {
                    print(index, terminator: "")
                    result = result + "\(index)"
                }
                self.dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            print(" Finished")
            completion(result)
        }
    }
    
    //vamos a solucionar un "ConditionRace"
    
    func sampleDataRaceSolved(completion: @escaping (String) ->()) {
        
        var result = "" //vamos a guardar lo que imprimimos en la consola en esta variable
        var serialQueue = DispatchQueue(label: "serialQueue")
        
        for c in series {
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave(9 como enter()
            lettersQueue.async {
                print("\(c)", terminator: "")
                serialQueue.sync {
                    result = result + c
                }
                
                self.dispatchGroup.leave()
            }
            dispatchGroup.enter() //siempre que metamos otra tarea hay que poner este .enter() y tiene que haber tantos leave(9 como enter()
            indexesQueue.async {
                if let index = series.firstIndex(where: { $0 == c}) {
                    print(index, terminator: "")
                    serialQueue.sync {
                        result = result + "\(index)"
                    }
                    self.dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                print(" Finished")
                completion(result)
            }
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
