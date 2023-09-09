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
use crate::repository::RepositoryError::{Duplicate, NotFound, Unavailable};

use actix_web::{
    delete, get,
    http::header::ContentType,
    put,
    web::{Data, Json, Path},
    HttpResponse, HttpResponseBuilder,
};
use validator::Validate;

#[put("/{username}")]
async fn create_user(
    db: Data<Engine>,
    path: Path<String>,
    payload: Json<User>,
) -> HttpResponseBuilder {
    let username = path.into_inner();
    let mut user = payload.into_inner();

    if user.username.is_none() {
        user.username = Some(username.clone());
    }

    if user.validate().is_err() {
        return HttpResponse::BadRequest();
    }

    match db.create_user(username.clone(), user.clone()).await {
        Ok(_) => HttpResponse::NoContent(),
        Err(error) => match error {
            Duplicate(_) => match db.update_user(username, user).await {
                Ok(_) => HttpResponse::NoContent(),
                Err(error) => match error {
                    Duplicate(_) => HttpResponse::Conflict(),
                    NotFound(_) => HttpResponse::NotFound(),
                    Unavailable(_) => HttpResponse::ServiceUnavailable(),
                },
            },
            NotFound(_) => HttpResponse::NotFound(),
            Unavailable(_) => HttpResponse::ServiceUnavailable(),
        },
    }
}

#[get("/{username}")]
async fn get_user(db: Data<Engine>, path: Path<String>) -> HttpResponse {
    let username = path.into_inner();

    match db.get_user(username.clone()).await {
        Ok(user) => {
            let days_till_birthday = user.days_till_birthday();
            if days_till_birthday == 0 {
                HttpResponse::Ok()
                    .content_type(ContentType::json())
                    .body(format!(
                        "{{\"message\":\"Hello, {}! Happy birthday!\"}}",
                        username
                    ))
            } else {
                HttpResponse::Ok()
                    .content_type(ContentType::json())
                    .body(format!(
                        "{{\"message\":\"Hello, {}! Your birthday is in {} day(s)\"}}",
                        username, days_till_birthday
                    ))
            }
        }
        Err(error) => match error {
            NotFound(_) => HttpResponse::NotFound().finish(),
            Unavailable(_) => HttpResponse::ServiceUnavailable().finish(),
            _ => HttpResponse::InternalServerError().finish(),
        },
    }
}

#[delete("/{username}")]
async fn delete_user(db: Data<Engine>, path: Path<String>) -> HttpResponseBuilder {
    let username = path.into_inner();

    match db.delete_user(username.clone()).await {
        Ok(_) => HttpResponse::NoContent(),
        Err(error) => match error {
            NotFound(_) => HttpResponse::NotFound(),
            Unavailable(_) => HttpResponse::ServiceUnavailable(),
            _ => HttpResponse::InternalServerError(),
        },
    }
}
