import SwiftUI

func initUserData() -> [SingleToDo] {
    var output: [SingleToDo] = []
    if let dataStored = UserDefaults.standard.object(forKey: "ToDoList") as? Data { //使用可选绑定检查UserDefaults中是否存在名为"ToDoList"的数据.如果存在.尝试将其转换为 Data 类型
        do {
            let data = try decoder.decode([SingleToDo].self, from: dataStored) //使用解码器将存储的数据解码成SingleToDo类型的数组
            for item in data {
                if !item.delete { //检查待办事项的delete属性是否为false如果是.则表示该项未被删除.可以加入到输出数组中
                    output.append(SingleToDo(title: item.title, duedate: item.duedate, isChecked: item.isChecked, isFavorite: item.isFavorite, id: output.count))
                }
            }
        } catch {
            // 处理错误
            print("Error decoding ToDoList: \(error)")
        }
    }
    return output
}

struct ContentView: View {

    @ObservedObject var Userdata: ToDo = ToDo(data: initUserData())

    @State var showFavoriteOnly = false

    @State var showEditingPage = false

    @State var editingMode = false

    @State var selection: [Int] = [] //多选的数组

    var body: some View {
        ZStack{
            NavigationView {
                ScrollView(.vertical, showsIndicators: true) { //滚动
                    VStack{
                        ForEach(self.Userdata.ToDoList) {item in
                                                         if !item.deleted {     //显示不被删除的
                                                             if !self.showFavoriteOnly || item.isFavorite {
                                                                 SingleCardView(index: item.id, editingMode: self.$editingMode, selection: self.$selection)
                                                                 .environmentObject(self.Userdata)
                                                                 .padding(.top)
                                                                 .padding(.horizontal)
                                                                 .animation(.spring()) //弹簧动画
                                                                 .transition(.slide) //滑动动画
                                                             }
                                                         }
                                                        }

                    }
                }
                .navigationBarTitle("提醒事项")
                .navigationBarItems(trailing:
                                        HStack(spacing: 20) {
                                            if self.editingMode{
                                                deleteButton(selection: self.$selection, editingMode: self.$editingMode)
                                                .environmentObject(self.Userdata)
                                                AllFavoriteButton(selection: self.$selection, editingMode: self.$editingMode)
                                                .environmentObject(self.Userdata)
                                            }
                                            if !self.editingMode {
                                                FavoriteButton(showFavoriteOnly: self.$showFavoriteOnly)
                                            }
                                            EditingButton(editingMode: self.$editingMode, selection: self.$selection)) //在右上角显示按钮 绑定editingMode的bool值
                                       })
        }

        HStack{
            Spacer()
            VStack{
                Spacer()
                Button(action: {
                    self.showEditingPage = true
                }) {
                    Image(systemName: "plus.ciecle.fill") //添加的图标
                    .resizable()
                    .sapectRatio(contentMode: .fit)
                    .frame(width: 80)
                    .foregroundColor(.blue)
                    .padding(.trailing)
                }
                .sheet(isPresented: self.showEditingPage, content: {
                    EditingPage()
                    .enciromentObject(self.Userdata)
                })
            }
        }
    }
}
}

struct AllFavoriteButton: View {

    @Binding var selection: [Int]
    @EnvironmentObject var Userdata: ToDo
    @Binding var editingMode: Bool

    var body: some View {
        Image(systemName: "star.lefthalf.fill")
        .imageScale(.large)
        .foregroundColor(.yellow)
        .onTapGesture {
            for i in self.selection {
                self.Userdata.ToDoList[i].isFavorite.toggle()
            }
            self.editingMode = false
        }

    }

}

struct FavoriteButton: View {
    @Binding var showFavoriteOnly: Bool

    var body: some View {
        Button(action: {
            self.showFavoriteOnly.toggle()
        }) {
            Image(systemName: self.showFavoriteOnly ? "star.fill" : "star")
            .imageScale(.large)
            .foregroundColor(.yellow)
        }
    }

}

struct EditingButton: View {

    @Binding var selection: [Int]

    @Binding var editingMode: Bool //绑定

    var body: some View {
        Button(action: {
            self.editingMode.toggle()
            self.selection.removeAll()
        }) {
            Image(systemName: "gear") //齿轮切换编辑模式
            .imageScale(.large)
        }
    }

}

struct deleteButton: View {

    @Binding var selection: [Int]
    @EnvironmentObject var Userdata: ToDo
    @Binding var editingMode: Bool


    var body: some View {
        Button(action: {
            for i in self.selection {
                self.Userdata.delete(id: i)
            }
            self.editingMode = false
        }) {
            Image(systemName: "trash")
            .imageScale(.large)
        }
    }


}

struct SingleCardView: View {

    @EnvironmentObject var Userdata: ToDo //监控Userdata
    var index: Int

    @State var showEditingPage = false

    @Binding var editingMode: Bool
    @Binding var selection: [Int]

    var body: some View {
        HStack {
            Rectangle() //构建一个矩形
            .frame(width: 6)
            .foregroundColor(.blue)
            //               .foregroundColor(Color("Card" + String(self.index % 5))) //通过自己加色卡 五颜六色

            //                if self.editingMode {
            //                    Button(action{
            //                    self.Userdata.delete(id: self.index)
            //                    self.editingMode = false
            //                }) {
            //                    Image(systemName: "trash")
            //                    .imageScale(.large)
            //                    .padding(.leading)
            //
            //                }



            Button(action{
                if !self.editingMode{
                    self.showEditingPage = true
                }
            }) {
                Group {
                    VStac(alignment: .leading, spacing: 6.0) {
                        Text(self.Userdata.ToDoList[index].title)
                        .font(.headline)
                        .foregroundColor(.black)
                        .fontWeight(.heavy)
                        Text(self.Userdata.ToDoList[index].duedate.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                    .padding(.leading)

                    Spacer()
                }
            }
            .sheet(isPresented: self.showEditingPage, content: {
                EditingPage(title: self.Userdata.ToDoList[self.index].title,
                                duedate: self.Userdata.ToDoList[self.index].duedate,
                                id: self.index, isFavorite: self.Userdata.ToDoList[self.index].isFavorite)
                .enciromentObject(self.Userdata)
            })

            if self.Userdata.ToDoList[index].isFavorite {
                Image(systemName: "star.fill")
                .imageScale(.large)
                .foregroundColor(.yellow)
            }

            if !self.editingMode {
                Image(systemName: self.Userdata.ToDoList[index].isChecked ? "checkmark.square.fill" : "square")
                .imageScale(.large) //控制图片大小
                .padding(.trailing)
                .onTapGesture {
                    self.Userdata.check(id: self.index)
                }
            }
            else {
                Image(systemName: self.selection.firstIndex(where: {$0 ==
                                                                         self.index}) == nil ? "circle" : "checkmark.circle.fill")
                .imageScale(.large)
                .padding(.trailing)
                .onTapGesture {
                    if self.selection.firstIndex(where: {
                        $0 == self.index
                    }) == nil {
                        self.selection.append(self.index)
                    }
                    else {
                        self.selection.remove(at:
                                                  self.selection.firstIndex(where: {
                                                      $0 == self.index
                                                  })!)    //这段代码定义了点击手势触发时的动作.如果selection数组中没有与self.index相等的元素.那么将self.index添加到selection数组中.如果selection数组中有与self.index相等的元素.那么从selection数组中移除该元素
                    }
                }
            }


        }
        .frame(height: 80)
        .background(Color.white)
        .cornerRadius(10) //阴影
        .shadow(radius: 10, x: 0, y: 10)

    }
}
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View {
        ContentView(Userdata: ToDo(data: [
            SingleToDo(title: "示例", duedate: Date())
        ]))
    }
}