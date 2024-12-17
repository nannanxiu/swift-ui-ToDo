import Foundation

var encoder = JSONEncoder()
var decoder = JSONDecoder()

class ToDo: ObservableObject {
    @Published var ToDoList: [SingleToDo]
    var count = 0
    
    init() {
        self.ToDoList = []
    }
    
    init(data: [SingleToDo]) {
        self.ToDoList = []
        for item in data {
            self.ToDoList.append(SingleToDo(title: item.title, 
                                          duedate: item.duedate, 
                                          isChecked: item.isChecked, 
                                          isFavorite: item.isFavorite,
                                          id: self.count))
            count += 1
        }
    }
    
    func check(id: Int) {
        self.ToDoList[id].isChecked.toggle()
        self.dataStore()
    }
    
    func add(data: SingleToDo) {
        self.ToDoList.append(SingleToDo(title: data.title, 
                                      duedate: data.duedate, 
                                      isFavorite: data.isFavorite, 
                                      id: self.count))
        self.count += 1
        self.sort()
        self.dataStore()
    }
    
    func edit(id: Int, data: SingleToDo) {
        self.ToDoList[id].title = data.title
        self.ToDoList[id].duedate = data.duedate
        self.ToDoList[id].isChecked = false
        self.ToDoList[id].isFavorite = data.isFavorite
        self.sort()
        self.dataStore()
    }
    
    func sort() {
        self.ToDoList.sort(by: { (data1, data2) in
            return data1.duedate.timeIntervalSince1970 < data2.duedate.timeIntervalSince1970
        })
        for i in 0..<self.ToDoList.count {
            self.ToDoList[i].id = i
        }
    }
    
    func delete(id: Int) {
        self.ToDoList[id].deleted = true
        self.sort()
        self.dataStore()
    }
    
    func dataStore() {
        let dataStored = try! encoder.encode(self.ToDoList)
        UserDefaults.standard.set(dataStored, forKey: "ToDoList")
    }
}

struct SingleToDo: Identifiable, Codable {
    var title: String = ""
    var duedate: Date = Date()
    var isChecked: Bool = false
    var isFavorite: Bool = false
    var deleted = false
    var id: Int = 0
}