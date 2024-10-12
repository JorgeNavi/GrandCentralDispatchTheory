import UIKit

//vamos a ver como funciona una cola en serie y otra en paralelo:

struct GDCQueues {
    
    let serialQueue = DispatchQueue(label: "io.keepcoding.serialQueue") //El label actúa como descripción de la cola o su "nombre" para dar información a los desarrolladores sobre qué es lo que hace la cola. Aquí se ve la importancia de saber escoger de manera adecuada el nombre de las variables
    let concurrentQueue = DispatchQueue(label: "io.keepcoding.concurrentQueue", attributes: .concurrent) //hay que notificar el atributo current para que la cola sea concurrente (que las tareas se vayan ejecutando a la vez). Si no se especifica es una cola en serie (como la de arriba) en la que las tareas se van ejecutando de forma secuencial.
    
    //en este metodo vamos a crear un for que va a pintar task 1, task 2 y task 3 y vamos a ver como funciona en una cola en serie y en otra concurrente
    func testCGDQueues(serie: Bool = true) {
        
        //vamos a crear una variable para la cola en serie. Asi en la logica si se usa esta variable va a usar la cola en serie y si no, usará la concurrente
        let queue = serie ? serialQueue : concurrentQueue// Este código en Swift utiliza el operador ternario para asignar a la variable queue uno de dos posibles valores: serialQueue o concurrentQueue. La elección entre estos dos depende del valor booleano de la variable serie.
        /*
         El operador ternario en Swift (y en muchos otros lenguajes de programación) es una forma corta de escribir una estructura condicional if-else. Se compone de tres partes:

             1.    Una condición (serie en este caso),
             2.    Un valor que se asigna si la condición es verdadera (serialQueue),
             3.    Un valor que se asigna si la condición es falsa (concurrentQueue).
         */
        for i in 1..<100 {
            
            queue.async {
                print("Task 1 \(i)")
            }
            
            queue.async {
                print("Task 2 \(i)")
            }
            
            queue.async {
                print("Task 3 \(i)")
            }
        }
    }
}

let testGDCQueues = GDCQueues() //instanciamos el struct
//testGDCQueues.testCGDQueues() //ejecutamos el metodo del struct, que en este caso ejecuta la cola en serie
testGDCQueues.testCGDQueues(serie: false) //llamamos al valor del operador ternario que es currentQueue
