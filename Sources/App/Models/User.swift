//
//  File.swift
//  
//
//  Created by Cameron Dunn on 2/26/21.
//

import Vapor
import Fluent


final class User: Content, ModelAuthenticatable{
    
    
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$passwordHash
    
    
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
    
    
    static let schema = "users"
    
    
    
    @ID(key: .id)
    var id : UUID?
    
    @Field(key: "username")
    var username: String
    
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "email")
    var email : String
    
    @Field(key: "first_name")
    var firstName : String
    
    @Field(key: "last_name")
    var lastName: String
    
    @Field(key: "recovery_question1")
    var recoveryQuestion1: String
    
    @Field(key: "recovery_answer1")
    var recoveryAnswer1: String
    
    @Field(key: "recovery_question2")
    var recoveryQuestion2: String
    
    @Field(key: "recovery_answer2")
    var recoveryAnswer2: String
    
    @Field(key: "birthday")
    var birthday: String
    
    @Field(key:"gender")
    var gender : String?
    
    init(){}
    
    init(username: String, passwordHash: String, email: String, firstName: String, lastName: String, recoveryQuestion1: String, recoveryAnswer1: String, recoveryQuestion2: String, recoveryAnswer2: String, birthday: String, gender: String?) {
        
        self.username = username.lowercased()
        self.passwordHash = passwordHash
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.recoveryQuestion1 = recoveryQuestion1
        self.recoveryAnswer1 = recoveryAnswer1
        self.recoveryQuestion2 = recoveryQuestion2
        self.recoveryAnswer2 = recoveryAnswer2
        self.birthday = birthday
        self.gender = gender
    }
    
}

extension User{
    struct Migration: Fluent.Migration{
        
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(User.schema)
                .id()
                .field("username", .string, .required)
                .field("password_hash", .string, .required)
                .field("email", .string, .required)
                .field("first_name", .string, .required)
                .field("last_name", .string, .required)
                .field("recovery_question1", .string, .required)
                .field("recovery_answer1", .string, .required)
                .field("recovery_question2", .string, .required)
                .field("recovery_answer2", .string, .required)
                .field("birthday", .string, .required)
                .field("gender", .string)
                .ignoreExisting()
                .create()
            
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(User.schema).delete()
        }
    }
    
    struct MakeUsernameAndEmailUnique: Fluent.Migration{
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema(User.schema)
                .unique(on: "username")
                .unique(on: "email")
                .update()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema(User.schema)
                .deleteUnique(on: "username")
                .deleteUnique(on: "email")
                .update()
        }
    }
}

extension User{
    
    
    struct Create: Content{
        var username : String
        var email : String
        var password: String
        var confirmPassword : String
        var firstName : String
        var lastName: String
        var recoveryQuestion1: String
        var recoveryAnswer1 : String
        var recoveryQuestion2: String
        var recoveryAnswer2: String
        var birthday: String
        var gender: String?
    }
}

extension User.Create : Validatable{
    static func validations(_ validations: inout Validations) {
        validations.add("username", as: String.self, is: !.empty)
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8..<17))
    }
}

extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}



extension User {
    
    final class Public: Content {
        var id: UUID?
        var firstName: String
        var lastName: String
        var username: String
        
        init(id: UUID?, firstName: String, lastName: String, username: String) {
            self.id = id
            self.firstName = firstName
            self.lastName = lastName
            self.username = username
        }
    }
    
    func convertToPublic() -> User.Public {
        return User.Public(id: id, firstName: firstName, lastName: lastName, username: username)
    }
}

