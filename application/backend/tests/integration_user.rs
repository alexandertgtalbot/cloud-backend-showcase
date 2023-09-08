// Path: github.com/alexandertgtalbot/cloud-backend-showcase/application/backend/tests/integration_user.rs
//
// Summary: Integration tests for the user API using a memory-based repository.
//
// Operations (validate):
// - Create a user.
// - Get a user:
//   - When the user's birthday is today.
//   - When the user's birthday is not today.
// - Update a user.
// - Delete a user.

#[cfg(test)]
mod integration {
    use actix_web::{http::header::ContentType, middleware, test, web, App};
    use backend::api::user::{create_user, delete_user, get_user};
    use backend::configs::Config;
    use backend::models::user::User;
    use envconfig::Envconfig;
    use std::sync::Arc;

    #[actix_web::test]
    async fn accept_create_user() {
        let config = Arc::new(Config::init_from_env().unwrap());
        let repository = backend::repository::Engine::connect(Arc::clone(&config)).await;
        let repository_data = web::Data::new(repository);

        let app = test::init_service(
            App::new()
                .wrap(middleware::Logger::default())
                .wrap(middleware::Logger::new("%a %{User-Agent}i"))
                .wrap(middleware::NormalizePath::trim())
                .app_data(repository_data.clone())
                .service(web::scope("/hello").service(create_user)),
        )
        .await;

        // Instantiate test user data.
        let username = String::from("test");
        let user_data = User {
            date_of_birth: String::from("2023-09-05"),
            username: None,
        };

        // Serialize the test user.
        let user_json = serde_json::to_string(&user_data).unwrap();

        // # Test case 1: Create a user.
        // - Request: `PUT /hello/<username>`.
        // - Payload: `{ "dateOfBirth": "YYYY-MM-DD" }`.
        // - Asserts: The response status is `204 No Content`.
        let request = test::TestRequest::put()
            .uri(&format!("/hello/{}", &username))
            .insert_header(ContentType::json())
            .set_payload(user_json.clone())
            .to_request();
        let response = test::call_service(&app, request).await;
        assert_eq!(response.status().as_u16(), 204);
    }

    #[actix_web::test]
    async fn accept_get_user_not_birthday() {
        let config = Arc::new(Config::init_from_env().unwrap());
        let repository = backend::repository::Engine::connect(Arc::clone(&config)).await;
        let repository_data = web::Data::new(repository);

        let app = test::init_service(
            App::new()
                .wrap(middleware::Logger::default())
                .wrap(middleware::Logger::new("%a %{User-Agent}i"))
                .wrap(middleware::NormalizePath::trim())
                .app_data(repository_data.clone())
                .service(web::scope("/hello").service(get_user)),
        )
        .await;

        // Instantiate test user data.
        let username = String::from("test");
        let user_data = User {
            date_of_birth: String::from("2023-09-05"),
            username: None,
        };

        // Serialize the test user.
        let user_json = serde_json::to_string(&user_data).unwrap();

        // # Test case 1: Create a user.
        // - Request: `PUT /hello/<username>`.
        // - Payload: `{ "dateOfBirth": "YYYY-MM-DD" }`.
        // - Asserts: The response status is `204 No Content`.
        let request = test::TestRequest::put()
            .uri(&format!("/hello/{}", &username))
            .insert_header(ContentType::json())
            .set_payload(user_json.clone())
            .to_request();
        let response = test::call_service(&app, request).await;
        assert_eq!(response.status().as_u16(), 204);

        // # Test case 2: Get a user.
        // - Request: `GET /hello/<username>`.
        // - Payload: `{ "dateOfBirth": "YYYY-MM-DD" }`.
        // - Asserts: The response status is `200 Ok`.
        let request = test::TestRequest::get()
            .uri(&format!("/hello/{}", &username))
            .insert_header(ContentType::json())
            .to_request();
        let get_response = test::call_service(&app, request).await;
        assert_eq!(get_response.status().as_u16(), 200);
        let response_body = test::read_body(get_response).await;
        assert_eq!(
            response_body,
            "{\"message\":\"Hello, test! Your birthday is in N day(s)\"}".to_string()
        );
    }

    #[actix_web::test]
    async fn accept_get_user_birthday_today() {
        let config = Arc::new(Config::init_from_env().unwrap());
        let repository = backend::repository::Engine::connect(Arc::clone(&config)).await;
        let repository_data = web::Data::new(repository);

        let app = test::init_service(
            App::new()
                .wrap(middleware::Logger::default())
                .wrap(middleware::Logger::new("%a %{User-Agent}i"))
                .wrap(middleware::NormalizePath::trim())
                .app_data(repository_data.clone())
                .service(web::scope("/hello").service(get_user)),
        )
        .await;

        // Instantiate test user data.
        let username = String::from("test");
        let user_data = User {
            date_of_birth: String::from("2023-09-05"),
            username: None,
        };

        // Serialize the test user.
        let user_json = serde_json::to_string(&user_data).unwrap();

        // # Test case 1: Create a user.
        // - Request: `PUT /hello/<username>`.
        // - Payload: `{ "dateOfBirth": "YYYY-MM-DD" }`.
        // - Asserts: The response status is `204 No Content`.
        let request = test::TestRequest::put()
            .uri(&format!("/hello/{}", &username))
            .insert_header(ContentType::json())
            .set_payload(user_json.clone())
            .to_request();
        let response = test::call_service(&app, request).await;
        assert_eq!(response.status().as_u16(), 204);

        // # Test case 2: Get a user.
        // - Request: `GET /hello/<username>`.
        // - Payload: `{ "dateOfBirth": "YYYY-MM-DD" }`.
        // - Asserts: The response status is `200 Ok`.
        let request = test::TestRequest::get()
            .uri(&format!("/hello/{}", &username))
            .insert_header(ContentType::json())
            .to_request();
        let get_response = test::call_service(&app, request).await;
        assert_eq!(get_response.status().as_u16(), 200);
        let response_body = test::read_body(get_response).await;
        assert_eq!(
            response_body,
            "{\"message\":\"Hello, test! Happy birthday!\"}".to_string()
        );
    }

    #[actix_web::test]
    async fn accept_update_user() {
        let config = Arc::new(Config::init_from_env().unwrap());
        let repository = backend::repository::Engine::connect(Arc::clone(&config)).await;
        let repository_data = web::Data::new(repository);

        let app = test::init_service(
            App::new()
                .wrap(middleware::Logger::default())
                .wrap(middleware::Logger::new("%a %{User-Agent}i"))
                .wrap(middleware::NormalizePath::trim())
                .app_data(repository_data.clone())
                .service(web::scope("/hello").service(create_user)),
        )
        .await;

        // Instantiate test user data.
        let username = String::from("test");
        let user_data = User {
            date_of_birth: String::from("2023-09-05"),
            username: None,
        };

        // Serialize the test user.
        let user_json = serde_json::to_string(&user_data).unwrap();

        // # Test case 1: Create a user.
        // - Request: `PUT /hello/<username>`.
        // - Payload: `{ "dateOfBirth": "YYYY-MM-DD" }`.
        // - Asserts: The response status is `204 No Content`.
        let request = test::TestRequest::put()
            .uri(&format!("/hello/{}", &username))
            .insert_header(ContentType::json())
            .set_payload(user_json.clone())
            .to_request();
        let response = test::call_service(&app, request).await;
        assert_eq!(response.status().as_u16(), 204);

        // # Test case 2: Update a user.
        // - Request: `PUT /hello/<username>`.
        // - Payload: `{ "dateOfBirth": "YYYY-MM-DD" }`.
        // - Asserts: The response status is `204 No Content`.
        let request = test::TestRequest::put()
            .uri(&format!("/hello/{}", &username))
            .insert_header(ContentType::json())
            .set_payload(user_json.clone())
            .to_request();
        let create_response = test::call_service(&app, request).await;
        assert_eq!(create_response.status().as_u16(), 204);
    }

    #[actix_web::test]
    async fn accept_delete_user() {
        let config = Arc::new(Config::init_from_env().unwrap());
        let repository = backend::repository::Engine::connect(Arc::clone(&config)).await;
        let repository_data = web::Data::new(repository);

        let app = test::init_service(
            App::new()
                .wrap(middleware::Logger::default())
                .wrap(middleware::Logger::new("%a %{User-Agent}i"))
                .wrap(middleware::NormalizePath::trim())
                .app_data(repository_data.clone())
                .service(
                    web::scope("/hello")
                        .service(create_user)
                        .service(delete_user),
                ),
        )
        .await;

        // Instantiate test user data.
        let username = String::from("test");
        let user_data = User {
            date_of_birth: String::from("2023-09-05"),
            username: None,
        };

        // Serialize the test user.
        let user_json = serde_json::to_string(&user_data).unwrap();

        // # Test case 1: Create a user.
        // - Request: `PUT /hello/<username>`.
        // - Payload: `{ "dateOfBirth": "YYYY-MM-DD" }`.
        // - Asserts: The response status is `204 No Content`.
        let request = test::TestRequest::put()
            .uri(&format!("/hello/{}", &username))
            .insert_header(ContentType::json())
            .set_payload(user_json.clone())
            .to_request();
        let response = test::call_service(&app, request).await;
        assert_eq!(response.status().as_u16(), 204);

        // # Test case 2: Delete a user.
        // - Request: `DELETE /hello/<username>`.
        // - Asserts: The response status is `204 No Content`.
        let request = test::TestRequest::delete()
            .uri(&format!("/hello/{}", &username))
            .to_request();
        let create_response = test::call_service(&app, request).await;
        assert_eq!(create_response.status().as_u16(), 204);
    }
}
