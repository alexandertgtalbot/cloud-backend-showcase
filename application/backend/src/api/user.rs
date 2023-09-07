// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/api/user.rs
//
// Summary: User API endpoint handlers.
//
// Operations (route handlers):
// - Create User (PUT).
// - Get User by name (GET).
// - Update User by name (PUT).
// - Delete User by name (DELETE).

use crate::models::user::User;
use crate::repository::Engine;
use actix_web::{
    delete, get, put,
    web::{Data, Json, Path},
    HttpResponse, HttpResponseBuilder,
};

#[put("/{username}")]
async fn create_user(
    _db: Data<Engine>,
    _path: Path<String>,
    _payload: Json<User>,
) -> HttpResponseBuilder {
    todo!()
}

#[get("/{username}")]
async fn get_user(_db: Data<Engine>, _path: Path<String>) -> HttpResponseBuilder {
    todo!()
}

#[delete("/{username}")]
async fn delete_user(_db: Data<Engine>, _path: Path<String>) -> HttpResponse {
    todo!()
}
