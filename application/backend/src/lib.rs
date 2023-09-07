// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/src/lib.rs
//
// Summary: Web framework functions to allow performance and stability assessment.
//
// Frameworks:
// - Actix.
// - Axum.
// - Rocket.

pub mod api;
pub mod configs;
pub mod models;
pub mod repository;

use actix_web::{middleware, web, App, HttpServer};
use api::user::{create_user, delete_user, get_user};
use repository::Engine;
use std::sync::Arc;

pub async fn run_actix(config: std::sync::Arc<configs::Config>) -> std::io::Result<()> {
    let repository = Engine::connect(Arc::clone(&config)).await;
    let repository_data = web::Data::new(repository);

    HttpServer::new(move || {
        App::new()
            .wrap(middleware::Logger::default())
            .wrap(middleware::Logger::new("%a %{User-Agent}"))
            .wrap(middleware::NormalizePath::trim())
            .app_data(repository_data.clone())
            .service(
                web::scope("/hello")
                    .service(create_user)
                    .service(get_user)
                    .service(delete_user),
            )
    })
    .bind(("127.0.0.1", 8080))?
    .run()
    .await
}

pub async fn run_axum(_config: std::sync::Arc<configs::Config>) -> std::io::Result<()> {
    todo!()
}

pub async fn run_rocket(_config: std::sync::Arc<configs::Config>) -> std::io::Result<()> {
    todo!()
}
