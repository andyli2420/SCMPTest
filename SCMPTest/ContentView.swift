//
//  ContentView.swift
//  SCMPTest
//
//  Created by Andy Li on 23/10/2023.
//

import SwiftUI


struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordValid = true
    @State private var isEmailValid = true
    
    @State private var authenicated = false
    @State private var loginToken = ""
    @State private var loading = false
    
    @State private var showAlert = false
    
    

    
    var body: some View {
        NavigationView {
            VStack {
                if (!loading && !authenicated){
                    LoginView(email: $email, password: $password, isEmailValid: $isEmailValid, isPasswordValid: $isPasswordValid, showAlert: $showAlert) {
                        if !(isEmailValid && isPasswordValid) {
                            showAlert = true
                            return
                        }
                        
                        loading = true
                        print("main", loading)
                    
                        
                        login(email: email, password: password) { result in
                            switch result {
                            case .success(let token) :
                                loginToken = token
                                authenicated = true
                                
                                loading = false

                            case .failure(let error) :
                                print("main Error", error)
                                loading = false
                            }
                        }
                    }
                    .padding()
                    
                }
                else {
                    if(authenicated){
                        StaffView(loginToken: $loginToken)
                    }else {
                        Text("loading...").font(.largeTitle)
                    }

                }
            }.padding()
        }
        .navigationTitle("SCMP Test")
    }
 
}

struct LoginView: View {
    @Binding var email: String
    @Binding var password: String
    @Binding var isEmailValid: Bool
    @Binding var isPasswordValid: Bool
    @Binding var showAlert: Bool
    var loginAction: () -> Void
    
    func isEmailValidation(_ email: String) -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return emailPredicate.evaluate(with: email)
    }
    
    func isPasswordValidation(_ password: String) -> Bool {
        let passwordRegex = "^[a-zA-Z0-9]{6,10}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    
    var body: some View {
        VStack {
            Text("SCMP Login!")
                .font(.largeTitle)
            
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding()
                .border(Color.black, width: 2)
                .cornerRadius(4)
                .onChange(of: email) { newValue in
                    isEmailValid = isEmailValidation(newValue)
                }
            
            SecureField("Password", text: $password)
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .border(Color.black, width: 2)
                .cornerRadius(4)
                .onChange(of: password) { newValue in
                    // Perform password validation
                    isPasswordValid = isPasswordValidation(newValue)
                }
            
            if !isEmailValid {
                Text("Invalid Email format")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            if !isPasswordValid {
                Text("Password should be 6-10 characters long and contain only letters and numbers.")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            Button("Login") {
                if !(isEmailValid && isPasswordValid) {
                    showAlert = true
                    return
                }
                
                loginAction()
            }
            .padding()
            .border(Color.black, width: 2)
            .cornerRadius(5)
            .background(Color.blue)
            .foregroundColor(.white)
        }
    }
}

struct StaffView: View {
    @Binding var loginToken: String
    
    @State private var data: UserListResponse?
    @State private var users: [User]?
    @State private var currentPage = 1
    
    var body: some View{
        VStack{
            Text("Login token : \(loginToken)")
                .font(.headline)
                .padding()
            

                List(users ?? [], id: \.id){ user in
                    
                    HStack{
                        AsyncImage(url: user.avatar) { image in
                                           image
                                               .resizable()
                                               .scaledToFit()
                                               .frame(width:60, height:60)
                                               .clipShape(Circle())
                                       } placeholder: {
                                           // Placeholder view while the image is being loaded
                                           ProgressView()
                                       }
        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack{
                                Text(user.firstName)
                                Text(user.lastName)
                                
                            }
                            Text(user.email)
                        }
                    }
            }
            
            
            if !(data?.totalPages == currentPage) {
                Button("Load More") {
                    Task{
                        do{
                            let data = try await getUsers(page: 2)
                            users = data.data
                            currentPage += 1
                            print("data", data)
                            print("currentPage", currentPage)
                        }catch{
                            print(error)
                        }
                    }
                }
                .padding()
                .border(Color.black, width: 2)
                .cornerRadius(5)
                .background(Color.blue)
                .foregroundColor(.white)
            }
        }
        .padding()
        .task {
            do {
                let data = try await getUsers()
                users = data.data
                print("dataa", data)
            } catch {
                print("Error: \(error)")
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


