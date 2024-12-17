import SwiftUI

struct EditingPage: View {

    @EnvironmentObject var Userdata: ToDo

    @State var title: String = ""
    @State var duedate: Date = Date()
    @State var isFavorite = false

    var id: Int? = nil

    @Environment(\.presentationMode) var presentation

    var body: some View{
        NavigationView{
            Form {
                Section(header: Text("事项")) {

                    TextField("事项内容", text: self.$title)
                    DatePicker(selection: self.$duedate, label: { Text("截止日期") })

                }
                Section{
                    Toggle(isOn: self.$isFavorite) {
                        Text("收藏")
                    }
                }
                Section{
                    Button(action: {
                        if self.id == nil {
                            self.Userdata.add(data: SingleToDo(title: self.title,
                                                       duedate: self.duedate, isFavorite: self.isFavorite))
                        }
                        else{
                            self.Userdata.edit(id: self.id!, data: SingleToDo(title: self.title, duedate: self.duedate, isFavorite: self.isFavorite))
                        }

                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("确认")
                    }

                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("取消")
                    }


                }
            }
            .navigationBarTitle("添加事项", displayMode: .inline)
        }
    }
}

struct EditingPage_Previews: PreviewProvider {
    static var previews: some View{
        EditingPage()
            .environmentObject(ToDo())
    }
}