//
//  File.swift
//  
//
//  Created by Cameron Dunn on 3/9/21.
//


import Fluent
import Vapor

final class UserToken: ModelTokenAuthenticatable, Content{
    static let schema = "UserTokens"
    
    static let valueKey = \UserToken.$value
    static let userKey = \UserToken.$user
    
    var isValid : Bool {
        true
    }
    
    @ID(key: .id)
    var id : UUID?
    
    @Field(key: "value")
    var value : String
    
    @Parent(key: "user_id")
    var user : User
    
    init(){}
    
    init(id: UUID? = nil, value: String, userID: User.IDValue){
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}


extension UserToken{

    struct TokenMigration: Fluent.Migration{
        
        var name : String { "UserTokens"}
        
        func prepare(on database: Database) -> EventLoopFuture<Void>{
            database.schema(name)
                .id()
                .field("value", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .unique(on: "value")
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void>{
            database.schema(name).delete()
        }
        
    }

}
