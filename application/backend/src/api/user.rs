// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/api/user.rs
//
// Summary: User API endpoint handlers.
//
// Operations (route handlers):
// - Create User (PUT).
// - Get User by name (GET).
// - Update User by name (PUT).
// - Delete User by name (DELETE).

#[put("/{username}")]
async fn create_user(
    db: Data<Engine>,
    path: Path<String>,
    payload: Json<User>,
) -> HttpResponseBuilder {
    todo!()
}

#[get("/{username}")]
async fn get_user(db: Data<Engine>, path: Path<String>) -> HttpResponseBuilder {
    todo!()
}

#[delete("/{username}")]
async fn delete_user(db: Data<Engine>, path: Path<String>) -> HttpResponse {
    todo!()
}
